edn = require 'edn'

matchObject = (expected, result, skipException)->
	for key, value of expected
		if !Object.prototype.hasOwnProperty.call(result, key)
			s = 'No "'+key+'" key in result object: '+result
			if skipException
				return s
			throw new Error s
		s = matchStruct value, result[key], skipException
		if s != true
			if skipException
				return s
			throw new Error s
	return true

matchArray = (expected, result, skipException)->
	if expected.length > result.length
		s = 'Expected array has more elements than result array: '+expected.length+' > '+result.length
		if skipException
			return s
		throw new Error s
	for value in expected
		found = false
		for i in [0...result.length]
			if matchStruct(value, result[i], true) == true
				found = true
				break
		if !found
			s = 'Cannot match "'+JSON.stringify(value)+'" in result array: "'+JSON.stringify(result)+'"'
			if skipException
				return s
			throw new Error s
	return true

matchStruct = (expected, result, skipException)->
	type_expected = type(expected)
	type_result = type(result)

	if (type_expected != type_result) && (!isRegExp(expected) || type_result != 'number')
		s = 'Incompatible types: '+type_expected+' != '+type_result
		if skipException
			return s
		throw new Error s
	if type_expected == 'array'
		s = matchArray expected, result, skipException
		if s != true
			if skipException
				return s
			throw new Error s
	else if type_expected == 'object'
		s = matchObject expected, result, skipException
		if s != true
			if skipException
				return s
			throw new Error s
	else if type_expected == 'string'
		if isRegExp expected
			re = new RegExp(expected.substring 1, expected.length - 1)
			if !re.test result
				s = 'RegExp not match: '+re+' != '+result
				if skipException
					return s
				throw new Error s
		else if expected != result
			s = 'Strings not match: '+expected+' != '+result
			if skipException
				return s
			throw new Error s
	else if type_expected == 'number'
		if expected != result
			s = 'Numbers not match: '+expected+' != '+result
			if skipException
				return s
			throw new Error s
	else
		s = 'Unknown type: '+type_expected
		if skipException
			return s
		throw new Error s
	return true

isArray = (value)->
	Object.prototype.toString.call(value) == '[object Array]'

isObject = (value)->
	Object.prototype.toString.call(value) == '[object Object]'

isRegExp = (value)->
	typeof(value) == 'string' && value.length >= 3 && value[0] == '/' && value[value.length - 1] == '/'

type = (value)->
	if isArray(value) then 'array' else typeof(value)

edn_to_json = (value)->
	if value == null
		return null
	if typeof(value) == 'string' || typeof(value) == 'number' || typeof(value) == 'boolean'
		return value
	if value instanceof Date
		return value.toISOString()
	if value.toString() == '[object Set]'
		return value.values
	if isArray value
		return value.splice 0
	if value instanceof edn.Keyword
		return value.namespace + '/' + value.name
	if value instanceof edn.Map && value.keys.length == 1 && value.keys[0].toString() == ':db/id'
		return value.values[0]
	throw new Error 'Unsupported value: '+(if value.inspect then value.inspect() else value)+', type: '+typeof value

module.exports.matchStruct = matchStruct
module.exports.type = type
module.exports.edn_to_json = edn_to_json
