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

	if type_expected != type_result
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
		if expected != result
			s = 'Strings not match: '+expected+' != '+result
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

type = (value)->
	if isArray(value) then 'array' else typeof(value)

module.exports.matchStruct = matchStruct
module.exports.type = type
