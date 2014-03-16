LOG_IN_MOTION_LEVEL = 2
LOG_IN_MOTION_FILENAME = 'logger.txt'

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    true
  end
end
