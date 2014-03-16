class SampleDelegate
  attr_accessor :onFileCreateCalled

  def onFileCreate(file)
    self.onFileCreateCalled = true
  end
end

describe "FileStore" do

  before do
    @baseDir = '1ux'
    @fileStore = MotionFileStore::FileStore.new({:directory=>@baseDir})
    @fileStore.numItemsPerFile = 2
    @fileStore.numItemsPerSave = 2

    6.times do |i|
      @fileStore.addItem("item#{i}")
    end
  end

  after do
    @fileStore.delete
  end

  it "should retrieve the itmes" do
    correctData = ['item0', 'item1','item2','item3','item4','item5']
    @fileStore.allItems.should == correctData
  end

  it "should create the correct amount of files" do
    @fileStore.fileCount.should == 3
  end

  it "should write any data in memory to file (on save)" do
    @fileStore.addItem('item6')
    @fileStore.save

    correctData = ['item0', 'item1','item2','item3','item4','item5', 'item6']
    @fileStore.allItems.should == correctData
    @fileStore.files.count.should == 4
  end

  it "should be able to retrieve the same data with a different instance" do
    fs = MotionFileStore::FileStore.new({:directory=>@baseDir})
    correctData = ['item0', 'item1','item2','item3','item4','item5']
    fs.allItems.should == correctData
  end

  it "should call delegate on file create" do
    del = SampleDelegate.new
    @fileStore.delegate = del
    @fileStore.addItem('item6')
    @fileStore.addItem('item7')
    del.onFileCreateCalled.should == true
  end
end
