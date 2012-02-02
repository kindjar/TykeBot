require 'spec_helper'
require 'shellwords'
require 'lib/command'

def action(options={},&callback)
  Command::Action.new(options,&callback)
end

def command(options={},&block)
  Command.new(options,&block)
end


describe Command do

  it 'should replace action with same arity' do
    a1 = action(:required=>:n)
    a2 = action(:required=>:n)
    command do |c|
      c.action a1
      c.action a2
    end.actions.should == [a2]
  end

  it 'should allow action overloading with different arity' do
    a1 = action(:required=>:n)
    a2 = action()
    command do |c|
      c.action a1
      c.action a2
    end.actions.should == [a1,a2]
  end

  it 'command foo action bar with one required arg should match "foo bar arg"' do
    c = command(:name=>:foo)
    a = c.action action(:name=>:bar,:required=>:n)
    c.match("foo bar arg","foo bar arg".shellsplit).should == [a,["arg"]]
  end

  it 'command should handle quoted args' do
    c = command(:name=>:foo)
    a = c.action action(:name=>:bar,:required=>:n)
    c.match("foo bar 'quoted arg'","foo bar 'quoted arg'".shellsplit).should == [a,["quoted arg"]]
  end

  it 'command should bundle up extra args' do
    c = command(:name=>:foo)
    a = c.action action(:name=>:bar,:required=>:n)
    c.match("foo bar quoted arg","foo bar quoted arg".shellsplit).should == [a,["quoted arg"]]
  end

end

describe Command::Action do

  it 'should sort properly high arity above low' do
    (action(:required=>:n) <=> action).should == -1
    (action(:required=>[:n,:p]) <=> action(:required=>:n)).should == -1
  end

  it 'should sort default over arity' do
    (action(:name=>'test') <=> action(:required=>:n)).should == -1
  end
 
  it 'should sort name above no name when both default and same arity' do
    (action(:name=>'test',:default=>true) <=> action).should == -1
  end

end
