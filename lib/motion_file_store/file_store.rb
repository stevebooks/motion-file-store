module MotionFileStore
  class FileStore
    include LogInMotion
    attr_accessor :directory,          :fileCount, 
                  :itemsPerFile,       :writeBufferSize, 
                  :itemsInCurrentFile, :itemBuffer

    def initialize(params={})
      if !params[:directory]
        raise "Please specify a directory. i.e. FileStore.new(:directory=>'mydir')"
      end

      self.directory = params[:directory]
      initializeFileCount
      self.itemsInCurrentFile = 0
      self.itemBuffer = []

      #defaults
      self.writeBufferSize = 10
      self.itemsPerFile = 100
      createDirectory
    end


    def addItem(item)
      self.itemBuffer << item

      if self.itemBuffer.size % self.writeBufferSize == 0
        writeItemBuffer
      end

    end

    #retrieves all the items from all files
    def allItems
      items = []

      files(true).each do |f|
        path = directoryWithPath + '/' + f
        contents = NSString.stringWithContentsOfFile(path, encoding:NSUTF8StringEncoding, error:nil)
        lines = contents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet)
        lines.pop #last element is always empty
        items += lines
      end

      return items
    end

    def currentFile
      "#{self.directoryWithPath}/#{self.fileCount}.data"
    end

    #deletes the directory and all files
    def delete
      fileManager = NSFileManager.defaultManager
      fileManager.removeItemAtPath(self.directoryWithPath, error:nil)
    end

    def directoryWithPath
      App.documents_path + "/#{self.directory}"
    end

    def files
      path = directoryWithPath + "/"
      fls = NSFileManager.defaultManager.contentsOfDirectoryAtPath(path, error:nil)
      return [] if fls.nil?

      #sort them
      fls = fls.sort do |a,b|
        a.split(".")[0].to_i <=> b.split(".")[0].to_i
      end

      return fls
    end

    def save
      writeItemBuffer
      @items = []
    end



    private
      def createDirectory
        fileManager = NSFileManager.defaultManager
        if !fileManager.fileExistsAtPath(self.directoryWithPath)
          unless fileManager.createDirectoryAtPath(self.directoryWithPath, withIntermediateDirectories:true, attributes:nil, error:nil)
            raise "Unable to create directory!"
          end
        end
      end

      def createFile
        path = self.currentFile
        data = "".dataUsingEncoding(NSUTF8StringEncoding)
        data.writeToFile(path, atomically:true)
      end

      #Looks through the current files to determine where the file count should start
      def initializeFileCount
        fls = self.files
        if fls.empty?
          self.fileCount = 0
          return
        end

        lastFile = fls.last
        count = lastFile.split(".")[0].to_i
        self.fileCount = count+1
      end

      def writeItemBuffer
        output = ""
        self.itemBuffer.each do |item|
          output += "#{item}\n"
          self.itemsInCurrentFile+=1

          if self.itemsInCurrentFile >= self.itemsPerFile
            writeToFile(output)
            self.fileCount+=1
            self.itemsInCurrentFile = 0
            output = ""
          end
        end

        writeToFile(output) unless output == ""
        self.itemBuffer = []
      end

      def writeToFile(str)
        fileManager = NSFileManager.defaultManager
        currFile = self.currentFile
        if !fileManager.fileExistsAtPath(self.currentFile)
          #puts "file does not exist, creating..."
          createFile
        end

        data = str.dataUsingEncoding(NSUTF8StringEncoding)
        myHandle = NSFileHandle.fileHandleForWritingAtPath(currFile)
        myHandle.seekToEndOfFile
        myHandle.writeData(data, dataUsingEncoding:NSUTF8StringEncoding)
      end

  end #class
end #module
