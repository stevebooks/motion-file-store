module MotionFileStore
  class FileStore
    include MotionLogger
    attr_accessor :directory,          :fileCount, 
                  :itemsPerFile,       :writeBufferSize, 
                  :itemsInCurrentFile, :itemBuffer

    def initialize(params={})
      if !params[:directory]
        raise "Please specify a directory. i.e. FileStore.new(:directory=>'mydir')"
      end
      debug "initialize motion file store"
      debug "Directory:#{params[:directory]}"

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
      #debug "Adding Item:#{item}"
      self.itemBuffer << item

      if self.itemBuffer.size % self.writeBufferSize == 0
        #debug 'hit our writeBufferSize'
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
      #debug 'save'
      writeItemBuffer
      @items = []
    end



    private
      def createDirectory
        fileManager = NSFileManager.defaultManager
        if !fileManager.fileExistsAtPath(self.directoryWithPath)
          #debug "creating a new Directory at path:#{self.directoryWithPath}"
          unless fileManager.createDirectoryAtPath(self.directoryWithPath, withIntermediateDirectories:true, attributes:nil, error:nil)
            raise "Unable to create directory!"
          end
        end
      end

      def createFile
        debug "creating new file name:#{self.currentFile}"
        path = self.currentFile
        data = "".dataUsingEncoding(NSUTF8StringEncoding)
        data.writeToFile(path, atomically:true)
      end

      #Looks through the current files to determine where the file count should start
      def initializeFileCount
        debug "initializeFileCount"
        fls = self.files
        if fls.empty?
          debug "no current files"
          self.fileCount = 0
          return
        end

        lastFile = fls.last
        debug "lastFile is:#{lastFile}"
        count = lastFile.split(".")[0].to_i
        debug "count:#{count}"
        self.fileCount = count+1
      end

      def writeItemBuffer
        #debug 'writeItemBuffer'
        output = ""
        self.itemBuffer.each do |item|
          output += "#{item}\n"
          self.itemsInCurrentFile+=1

          if self.itemsInCurrentFile >= self.itemsPerFile
            #debug "Hit our max items per file"
            writeToFile(output)
            self.fileCount+=1
            self.itemsInCurrentFile = 0
            output = ""
          end
        end

        writeToFile(output) unless output == ""
        #debug "resetting itemBuffer"
        self.itemBuffer = []
      end

      def writeToFile(str)
        #debug "writeToFile:\n#{str}"
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
