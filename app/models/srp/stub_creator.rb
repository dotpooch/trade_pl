# encoding: utf-8

class StubCreator

  def initialize
    self
  end

  def exists?(_stub)
    Stub.where('stub' => _stub).first.nil? ? false : true
  end

  def self.format_stub(_stub)
  #gsub(/^[0-9\.]/, ''))
    stub = _stub.downcase.gsub(/[^0-9A-Za-z]/, '.')
    # using these causes an error
    #stub = stub.gsub('...', '.')
    #stub = stub.gsub('..', '.')

    stub = stub.gsub('...', '_')
    stub = stub.gsub('..', '_')
    stub = stub.gsub('.', '_')
    stub = stub[0..-2] if stub[-1] == "_"
    stub
  end

  def find_or_create(_name)
    name = StubCreator.format_stub _name
    stub = Stub.where('stub' => name).first
    if stub.nil?
      stub = Stub.new
      stub.stub = name
      stub.save
   end 
   stub
  end

end
