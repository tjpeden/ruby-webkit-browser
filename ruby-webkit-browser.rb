require 'webkit'

class Browser
  
  HOME = "http://www.google.com/"
  
  attr_accessor :webview, :scroller, :addressbar, :statusbar
  
  def initialize parent
    @webview = Gtk::WebKit::WebView.new
    @scroller = Gtk::ScrolledWindow.new
    @addressbar = Gtk::Entry.new
    @statusbar = Gtk::Statusbar.new
    
    @default_zoom_level = webview.zoom_level
    
    statusbar.has_resize_grip = false
    
    parent.add create_all
    
    setup_connections
    go_home
  end
  
  def go_home
    webview.open HOME
  end
  
  def zoom_normal
    webview.zoom_level = @default_zoom_level
  end
  
  private
  
    def create_all
      vbox = Gtk::VBox.new
      
      vbox.pack_start create_navigation_bar, false
      vbox.pack_start create_webview
      vbox.pack_start statusbar, false
      
      vbox
    end
    
    def create_navigation_bar
      hbox = Gtk::HBox.new
      
      hbox.pack_start create_toolbar, false
      hbox.pack_start addressbar
      
      hbox
    end
    
    def create_toolbar
      toolbar = Gtk::Toolbar.new
      toolbar.toolbar_style = Gtk::Toolbar::Style::ICONS
      
      back = toolbar.append( Gtk::Stock::GO_BACK ) { webview.go_back }
      forward = toolbar.append( Gtk::Stock::GO_FORWARD ) { webview.go_forward }
      stop = toolbar.append( Gtk::Stock::STOP ) { webview.stop_loading }
      reload = toolbar.append( Gtk::Stock::REFRESH ) { webview.reload }
      home = toolbar.append( Gtk::Stock::HOME ) { go_home }
      
      toolbar
    end
    
    def create_webview
      scroller.set_policy Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC
      scroller.add_with_viewport webview
      
      scroller
    end
    
    def setup_connections
      addressbar.signal_connect( 'activate' ) { webview.open addressbar.text }
      
      status_context = statusbar.get_context_id( "Link" )
      webview.signal_connect( 'hovering-over-link' ) do |view, title, uri|
        statusbar.pop( status_context )
        statusbar.push( status_context, uri ) if uri
      end
      
      # Change address bar to the correct uri
      webview.signal_connect( 'load-finished' ) do |view, frame|
        addressbar.text = view.uri
      end
      
      # Add zoom commands to the context menu
      webview.signal_connect( 'populate-popup' ) do |view, menu|
        separator = Gtk::SeparatorMenuItem.new.show
        
        menu.append separator
        
        zoom_item = Gtk::MenuItem.new( "_Zoom" ).show
        
        menu.append zoom_item
        
        zoom_menu = Gtk::Menu.new
        
        zoom_item.submenu = zoom_menu
        
        zoom_in_item = Gtk::MenuItem.new( "_Larger" ).show
        zoom_in_item.signal_connect( 'activate' ) { webview.zoom_in }
        
        zoom_menu.append zoom_in_item
        
        zoom_normal_item = Gtk::MenuItem.new( "_Normal" ).show
        zoom_normal_item.signal_connect( 'activate' ) { zoom_normal }
        
        zoom_menu.append zoom_normal_item
        
        zoom_out_item = Gtk::MenuItem.new( "_Smaller" ).show
        zoom_out_item.signal_connect( 'activate' ) { webview.zoom_out }
        
        zoom_menu.append zoom_out_item
      end
    end
  
end

