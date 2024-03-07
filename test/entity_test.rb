require 'test_helper'

describe 'entity' do
  it '#1 hash to attr_reader' do
    h = { a: 'a', b: 'B' }
    e = WrAPI::Request::Entity.create(h)
    assert value(e.a).must_equal h[:a], 'e.a'
    assert value(e.b).must_equal h[:b], 'e.b'
    e.a += e.a
  end
  it '#2 hash to attr-writer' do
    h = { a: 'a', b: 'B' }
    e = WrAPI::Request::Entity.create(h)
    assert value(e.a).must_equal h[:a], 'e.a'
    assert value(e.b).must_equal h[:b], 'e.b'
    e.a += e.a
    assert value(e.a).must_equal h[:a] + h[:a], "e.a='aa'"
  end
  it '#3 a.b.c' do
    h = {
      'userId': 'string',
      'taskId': 'string',
      'source': 'GMAIL',
      'entityName': 'string',
      'lastBackupDate': 'string',
      'lastBackupAttemptDate': 'string',
      'backupDuration': 0,
      'size': 0,
      'empty_array': [],
      'backupStatus': [
        {
          'subSource': 'string',
          'status': 'string',
          'error': 'string',
          'errFAQLink': 'string'
        }
      ]
    }

    e = WrAPI::Request::Entity.create(h)
    assert value(e.userId).must_equal h[:userId], 'e.userId'
    assert value(e.backupStatus.first.subSource).must_equal h[:backupStatus].first[:subSource],
                                                            'e.backupStatus.first.subSource'
    assert value(e.empty_array).must_equal [], 'e.empty_array'
  end
  it '#4 to_json' do
    h = {
      'userId': 'string',
      'taskId': 'string',
      'source': 'GMAIL',
      'entityName': 'string',
      'lastBackupDate': 'string',
      'lastBackupAttemptDate': 'string',
      'backupDuration': 0,
      'size': 0,
      'backupStatus': [
        {
          'subSource': 'string',
          'status': 'string',
          'error': 'string',
          'errFAQLink': 'string'
        }
      ],
      'nested': {a:'a',b:'b'}
    }

    e = WrAPI::Request::Entity.create(h)
    assert value(e.to_json).must_equal h.to_json, 'e.to_json'
    deep = e.backupStatus
    assert value(deep.to_json).must_equal h[:backupStatus].to_json, 'e.to_json'
    assert value(e.nested.attributes).must_equal({ 'a' => 'a', 'b' => 'b' }), 'nested hash'
  end
  it '#5 array' do
    a = [{
      'userId': 'string',
      'taskId': 'string',
      'source': 'GMAIL',
      'entityName': 'string',
      'lastBackupDate': 'string',
      'lastBackupAttemptDate': 'string',
      'backupDuration': 0,
      'size': 0,
      'backupStatus': [
        {
          'subSource': 'string',
          'status': 'string',
          'error': 'string',
          'errFAQLink': 'string'
        }
      ]
    }]

    e = WrAPI::Request::Entity.create(a)
    assert value(e.count).must_equal a.count, 'e.count'
    assert value(e.first.userId).must_equal a.first[:userId], 'e.first.userId'
    assert value(e[0].userId).must_equal a[0][:userId], 'e[0].userId'
  end
  it '#6 string entity' do
    e = WrAPI::Request::Entity.create('test')

    assert value(e.test).must_equal 'test', 'call method for string'
    assert_raises NoMethodError do
      e.test2
    end
  end
  it '#7 {}/[]/nil entity' do
    e = WrAPI::Request::Entity.create({})
    assert e.is_a?(WrAPI::Request::Entity), 'must be an Entity'

    assert value(e.attributes).must_equal({}), 'empty hash expected'
    e = WrAPI::Request::Entity.create([])
    assert e.is_a?(Array), 'must be an Array'
    assert value(e).must_equal([]), 'empty array expected'
    e = WrAPI::Request::Entity.create([{a: 'a'}])
    assert value(e.first.attributes).must_equal({ 'a' => 'a' }), 'single hash expected'
    e = WrAPI::Request::Entity.create(nil)
    assert_nil e, 'nil expected'
  end
  it "#8 create clones" do
    user = {
      'user_id'=> 1,
      'user_name'=> 'John Doe'
    }
    e = WrAPI::Request::Entity.create(user)
    user['user_id'] = 2
    assert !e.to_json.eql?(user.to_json), 'check updated json field does not impact entity'
  end
  it "#9 update json" do
    user = {
      'user_id'=> 1,
      'user_name'=> 'John Doe',
      'nested_a' => [{'a'=>'ha'},{'b'=>'hb'}],
      'nested_a_num' => [1,2,3,4,5,6,7,8,9],
      'nested_h' => {'a'=>'a','b'=>'b','c'=>'c'}
    }
    e = WrAPI::Request::Entity.create(user)
    e.user_id = user['user_id'] = 2
    assert value(e.to_json).must_equal user.to_json, 'check updated json field'
    assert value(e.nested_h.to_json).must_equal(user['nested_h'].to_json), 'check nested array'
    e.nested_h = user['nested_h'] = {'x'=>'x','y'=>'y'}
    assert value(e.nested_h.to_json).must_equal(user['nested_h'].to_json), 'check nested array update'
    e.nested_a.first.a = user['nested_a'].first['a'] = 'HA'
    assert value(e.nested_a.first.a).must_equal('HA'), 'check nested array update'
    assert value(e.nested_a_num.first).must_equal 1, 'check numeric array'
    e.nested_a_num[0] = user['nested_a_num'][0] = 2
    assert value(e.to_json).must_equal user.to_json, 'check numeric array'

    e.nested_h = user['nested_h'] = {'d'=>'d','e'=>'e'}
    assert value(e.to_json).must_equal user.to_json, 'check updated hash'

    e.nested_h = WrAPI::Request::Entity.create(user['nested_h'])
    assert value(e.to_json).must_equal user.to_json, 'check updated entity hash'
  end
end
