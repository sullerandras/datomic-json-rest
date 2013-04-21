assert = require("assert")
util = require("../features/support/util")

assert_equal = (expected, result, error_message)->
  assert.strictEqual result, expected, error_message

assert_not_equal = (expected, result, error_message)->
  assert.notStrictEqual result, expected, error_message

describe 'util', ->
  describe '#type', ->
    it 'returns "array" for arrays', ->
      assert_equal 'array', util.type [1, 2]

    it 'returns "object" for objects', ->
      assert_equal 'object', util.type {key: 'value'}

    it 'returns "string" for strings', ->
      assert_equal 'string', util.type 'value'

  describe '#matchStruct', ->
    it 'matches strings', ->
      assert_equal true, util.matchStruct 'string', 'string'

    it 'matches hashes with primitive values', ->
      assert_equal true, util.matchStruct {key: 'string'}, {key: 'string'}
      assert_equal true, util.matchStruct {key: 'string'}, {key: 'string', extra: 'no problem'}

    it 'matches arrays with primitive values', ->
      assert_equal true, util.matchStruct ['string'], ['string']
      assert_equal true, util.matchStruct ['string'], ['extra...', 'string', '...values are ignored']
      assert_equal true, util.matchStruct ['string', 'other'], ['other', 'extra...', 'string', '...values are ignored']

    it 'matches arrays with complex values', ->
      assert_equal true, util.matchStruct [{key: 'string'}], [{key: 'string'}]
      assert_equal true, util.matchStruct [{key: 'string'}], [{key: 'string', extra: 'no problem'}]
      assert_equal true, util.matchStruct [{key: 'string'}], ['some extra value', {key: 'string', extra: 'no problem'}]
      assert_equal true, util.matchStruct [{name: 'user', attrs: [{name: 'age'}]}], [{name: 'db', attrs: []}, {name: 'user', attrs: [{name: 'id'}, {name: 'age'}]}]
      assert_not_equal true, util.matchStruct {name: 'wage'}, {name: 'age'}, true
      # assert_not_equal true, util.matchStruct [{name: 'wage'}], [{name: 'id'}, {name: 'age'}]
      # assert_not_equal true, util.matchStruct [{attrs: [{name: 'wage'}]}], [{attrs: [{name: 'id'}, {name: 'age'}]}]
      # assert_not_equal true, util.matchStruct [{name: 'user', attrs: [{name: 'wage'}]}], [{name: 'db', attrs: []}, {name: 'user', attrs: [{name: 'id'}, {name: 'age'}]}]

    it 'matches hashes with complex values', ->
      assert_equal true, util.matchStruct {key: ['string']}, {key: ['string']}
      assert_equal true, util.matchStruct {key: ['string']}, {key: ['extra...', 'string', '...values are ignored']}
      assert_equal true, util.matchStruct {key: ['string', 'other']}, {key: ['other', 'extra...', 'string', '...values are ignored']}
