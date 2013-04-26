assert = require 'assert'
util = require '../features/support/util'
edn = require 'edn'

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

    it 'matches numbers', ->
      assert_equal true, util.matchStruct 1234, 1234

    it 'matches regular expression to strings or numbers', ->
      assert_equal true, util.matchStruct '/[a-z]+/', 'string'
      assert_equal 'RegExp not match: /[0-9]+/ != string', util.matchStruct '/[0-9]+/', 'string', true
      assert_equal true, util.matchStruct '/[0-9]+/', 123456

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

  describe '#edn_to_json', ->
    it 'converts null to null', ->
      assert_equal null, util.edn_to_json null

    it 'converts string to string', ->
      assert_equal 'string', util.edn_to_json 'string'

    it 'converts number to number', ->
      assert_equal 123.5, util.edn_to_json 123.5

    it 'converts boolean to boolean', ->
      assert_equal true, util.edn_to_json true

    it 'converts Date to ISO string', ->
      assert_equal '2013-04-12T13:19:51.000Z', util.edn_to_json new Date('Fri Apr 12 2013 21:19:51 GMT+0800 (HKT)')

    it 'converts keyword to string', ->
      assert_equal 'community/name', util.edn_to_json edn.parse ':community/name'

    it 'converts Map with one :db/id key to integer', ->
      assert_equal 17592186045539, util.edn_to_json edn.parse '{:db/id 17592186045539}'

    it 'converts Array with primitive values', ->
      assert_equal '["John",17592186045614]', JSON.stringify util.edn_to_json edn.parse '["John", 17592186045614]'

    it 'converts Set with primitive values to array', ->
      assert_equal '["string",123456]', JSON.stringify util.edn_to_json edn.parse '#{"string", 123456}'
