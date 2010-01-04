require 'ruby-webkit-browser'

class BrowserWindow < Gtk::Window

  TITLE = "Ruby Webkit Browser"
  
  attr_accessor :browser
  
  @@count = 0
  
  def initialize
    super
    @@count += 1
    
    @browser = Browser.new self # Browser adds itself to the parent widget you pass
    
    self.title = TITLE
    border_width = 1
    resize 800, 600
    
    setup_webview
   
    signal_connect( 'destroy' ) do
      Gtk.main_quit if only?
      @@count -= 1
    end
    
    signal_connect( 'window-state-event' ) do |widget, event|
      @window_state = event.new_window_state
    end
    
    signal_connect( 'key-press-event' ) do |widget, event|
      if event.keyval == Gdk::Keyval::GDK_F12
        fullscreen? ? unfullscreen : fullscreen
      end
      
      if event.keyval == Gdk::Keyval::GDK_Escape and fullscreen?
        unfullscreen
      end
    end
    show_all
  end
  
  private
  
    def setup_webview
      # Create a new browser window, when requested
      browser.webview.signal_connect( 'create-web-view' ) do
        BrowserWindow.new.browser.webview
      end
      
      # Change the window title when the page title changes
      browser.webview.signal_connect( 'title-changed' ) do |view, frame, page_title|
        new_title = "#{TITLE} - #{page_title}"
        self.title = new_title if self.title != new_title
      end
    end
  
    def only?
      @@count == 1
    end
    
    def fullscreen?
      @window_state & Gdk::EventWindowState::FULLSCREEN != 0
    end

end

if __FILE__ == $0
  BrowserWindow.new
  Gtk.main
end
