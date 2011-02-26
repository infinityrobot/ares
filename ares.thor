# ARES
class Ares < Thor
  
  # ADD GEM TO DEVELOPMENT GROUP
  # gemfile = File.read("Gemfile")
  # gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem \"gemname\"")
  # File.delete("Gemfile")
  # File.open("Gemfile", "+w").write(gemfile)
  
  
  # VARIABLES
  DEFAULT_FILES = ["public/index.html", "public/images/rails.png"]
  
  # --------------------------------------------------------------------------------------------------- #
  # new - Create a new app                                                                              #
  # --------------------------------------------------------------------------------------------------- #
  desc "new", "Create a new Rails app."
  def new
    
    # => Name the app...
    say "Creating a new Rails app using Ares..."
    app_name = ask("What would you like your app to be named? ", :cyan).downcase
    app_name = app_name.gsub!(/[^a-z0-9\-_]+/, "_") if app_name.include? " "
    
    # => Create the app and change directory
    say "Creating the Rails app #{app_name}."
    system "rails new #{app_name} -q"
    Dir.chdir(app_name)
    app_directory = Dir.pwd
    
    # => Initialize the Git repository
    say "Initializing a Git repository for #{app_name}."
    system "git init -q"
    
    # => Add .gitignore
    say "Adding .gitignore file."
    gitignore = File.new(".gitignore", "r+")
    gitignore.write(".bundle\ndb/*.sqlite3\nlog/*.log\nlog/*.pid\ntmp/**/*\ntest\npublic/uploads\n")
    
    # => Initial commit
    system "git add ."
    system "git commit -a -m \"Initial commit.\" -q"
    say "Rails app created and Git repository initialized in #{app_directory}", :green
    
    # => Invoke other tasks!
    invoke :default_files
    invoke :jquery
    invoke :home
    invoke :forms
    invoke :testing
    invoke :devise
    invoke :omniauth
    invoke :pivotal
    invoke :github
    invoke :capsitrano
    
    # => EDIT README TO SHOW ALL OPTIONS INSTALLED
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # default_files - Remove Default Rails files                                                          #
  # --------------------------------------------------------------------------------------------------- #
  desc "default_files", "Removes the default Rails files and clears the README"
  def default_files
    if yes? "Remove the default Rails files? (y/n) ", :cyan
      DEFAULT_FILES.each do |file|
        File.delete(file)
        say "Deleted the file #{file}"
      end
      system "git add ."
      system "git commit -a -m \"Removed default Rails files.\" -q"
      say "The default Rails files have been deleted!", :green
    end
    if yes? "Clear the current README? (y/n) ", :cyan
      File.open("README", "w").write("")
      say "README has been cleared.", :green
      system "git add ."
      system "git commit -a -m \"Cleared the README.\" -q"
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # jquery - Set jQuery as the default javascript framework                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "jquery", "Set jQuery as the default javascript framework instead of Prototype."
  def jquery
    if yes? "Would you like to use jQuery instead of Prototype? (y/n) ", :cyan
      jquery_ui = yes?("Would you like to install jQuery UI as well? (y/n) ", :yellow) ? true : false
      
      # => Remove Prototype files
      say "Adding jquery-rails gem to Gemfile and running bundle update..."
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem \"jquery-rails\"")
      File.delete("Gemfile")
      File.open("Gemfile", "+w").write(gemfile)
      system "bundle install --quiet"
      system "rails generate jquery:install #{"--ui" if jquery_ui == true}"
      say "Installed jQuery#{" & jQuery UI" if jquery_ui == true} as default javascript framework.", :green
      
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Installed jQuery as default javascript framework.\" -q"
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # home - Set up Home controller                                                                       #
  # --------------------------------------------------------------------------------------------------- #
  desc "home", "Add a root controller for a home / welcome page."
  def home
    if yes? "Would you like to create a root controller for a home page for your app? (y/n) ", :cyan
      
      # => Name the root controller
      root_controller_name = ask?("What would you like to name your Home Page controller?", :cyan).downcase
      root_controller_name = root_controller_name.gsub!(/[^a-z0-9\-_]+/, "_") if root_controller_name.include? " "
      
      # => Generate the controller
      say "Creating the controller \"#{root_controller_name}\"..."
      system "rails generate controller #{root_controller_name} index --template-engine=haml" # !!! CHANGE TO GLOBAL OPTION LATER
      
      # => Add root route to routes.rb
      routes = File.read("config/routes.rb")
      routes = routes.gsub("routes.draw do", "routes.draw do\n\n  root :to => 'home#index'")
      File.delete("config/routes.rb")
      File.open("config/routes.rb", "w+").write(routes)
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # testing - Set up Testing Framworks                                                                  #
  # --------------------------------------------------------------------------------------------------- #
  desc "testing", "Sets up testing frameworks for your app."
  def testing
    cucumber = yes?("Would you like to use Cucumber for integration testing? (y/n) ", :cyan) ? true : false
    rspec = yes?("Would you like to use RSpec for unit testing? (y/n) ", :cyan) ? true : false
    seed = yes?("Would you like to seed test data in your tests? [Adds machinist and faker gems] (y/n) ", :cyan) ? true : false
    fakeweb = yes?("Would you like to block HTTP requests in your tests? [Adds fakeweb gem] (y/n) ", :cyan) ? true : false
    
    # => Check for Cucumber options / add-ins
    if cucumber
      capybara = yes?("Would you like to use Capybara for interactions with Cucumber? (y/n) ", :cyan) ? true : false
      email_spec = yes?("Would you like to test the sending / receipt of emails in your Cucumber tests? [Adds email_spec gem and steps] (y/n) ", :cyan) ? true : false
    end
    
    # => Add required gems to Gemfile
    if cucumber || rspec || seed || fakeweb
      say "Adding testing / development gems to Gemfile.."
      gemfile = File.open("Gemfile", "a")
      gemfile.write(
%Q{
# TESTING / DEVELOPMENT GEMS
group :development, :test do
#{"  gem 'cucumber'
  gem 'cucumber-rails'            # => Rails generators for Cucumber - http://github.com/aslakhellesoy/cucumber-rails" if cucumber}
#{"  gem 'capybara'                  # => Rails testing driver - http://github.com/jnicklas/capybara" if capybara}
#{"  gem 'rspec'                     # => Behaviour driven development for ruby - http://github.com/rspec/rspec
  gem 'rspec-rails'               # => RSpec extension library for Ruby on Rails - http://github.com/rspec/rspec-rails" if rspec}
#{"  gem 'database_cleaner'          # => For cleaning database between test sessions - http://github.com/bmabey/database_cleaner
  gem 'spork'                     # => DRb server for testing frameworks - http://github.com/timcharper/spork
  gem 'launchy'                   # => Helper class for launching applications - http://copiousfreetime.rubyforge.org/launchy/" if cucumber || rspec}
#{"  gem 'machinist'                 # => For creating seed data / database population - http://github.com/notahat/machinist
  gem 'faker'                     # => For generating random data - http://faker.rubyforge.org/" if seed}
#{"  gem 'fakeweb'                   # => For blocking external HTTP access in tests - http://github.com/chrisk/fakeweb" if fakeweb}
#{"  gem 'email_spec'                # => For testing ActionMailer in Cucumber - http://github.com/bmabey/email-spec" if email_spec}
end
})
      # => Bundle update to install gems and commit changes
      say "Running bundle install..."
      system "bundle install --quiet"
      system "git add ."
      system "git commit -a -m \"Added testing gems to Gemfile.\" -q"
    end
    
    # => Install RSpec
    if rspec
      say "Installing RSpec..."
      system "rails generate rspec:install --quiet"
      say "RSpec installed!", :green
      system "git add ."
      system "git commit -a -m \"Added RSpec for unit testing.\" -q"
    end
    
    # => Run Cucumber generator
    if cucumber
      say "Installing Cucumber..."
      system "rails generate cucumber:install#{" --capybara" if capybara == true}#{" --rspec" if rspec == true} --quiet"
      say "Cucumber installed!", :green
      system "git add ."
      system "git commit -a -m \"Added Cucumber for integration testing.\" -q"
    end
    
    # => Run email_spec generator commands
    if email_spec
      say "Installing Cucumber email steps..."
      system "rails generate email_spec:steps --quiet"
      say "Cucumber email steps installed to features/step_definitions/email_steps.rb!", :green
      system "git add ."
      system "git commit -a -m \"Added email_spec test steps for testing emails with Cucumber.\" -q"
    end
    
    # => Installing Fakeweb
    if fakeweb
      say "Installing Fakeweb..."
      fakeweb_file = File.new("features/support/fakeweb.rb", "w+")
      fakeweb_file.write("# Fakeweb URI definitions\nFakeWeb.allow_net_connect = false # Doesn't allow testing to connect to the internet")
      say "Fakeweb installed with config in features/support/fakeweb.rb!", :green
      system "git add ."
      system "git commit -a -m \"Added Fakeweb for blocking HTTP requests in tests.\" -q"
    end
    
    # => Success notice
    say "Test suite successfully installed!", :green
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # devise - Set up Devise authentication                                                               #
  # --------------------------------------------------------------------------------------------------- #
  desc "devise", "Add User authentication with Devise."
  def devise
    
    # => Add Devise gem to Gemfile
    say "Adding Devise gem to Gemfile..."
    gemfile = File.read("Gemfile")
    gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem 'devise'                      # => For user authentication - http://github.com/plataformatec/devise")
    File.delete("Gemfile")
    File.open("Gemfile", "+w").write(gemfile)
    say "Running bundle install..."
    system "bundle install --quiet"
    system "git add ."
    system "git commit -a -m \"Added Devise to Gemfile.\" -q"
    
    # => Install Devise
    say "Installing Devise..."
    system "rails generate devise:install -q"
    say "Devise is installed!", :green
    system "git add ."
    system "git commit -a -m \"Installed Devise for authentication.\" -q"
    
    # => Add Devise model
    devise_model = ask("What would you like to name your Devise model? (User, Admin, etc) ", :cyan).downcase
    devise_model = devise_model.gsub!(/[^a-z0-9\-_]+/, "_") if devise_model.include? " "
    say "Generating the Devise model..."
    system "rails generate devise #{devise_model} -q"
    say "Devise model for #{devise_model} generated!", :green
    system "git add ."
    system "git commit -a -m \"Added #{devise_model} model for Devise authentication.\" -q"
    
    # => Add custom Devise routes
    if yes? "Would you like to Ad some custom routes for your Devise model? (y/n)", :cyan
      # Define routes to use
      devise_sign_in_route = ask "What would you like your Devise Sign In route to be? (ie, login)", :cyan
      devise_sign_out_route = ask "What would you like your Devise Sign Out route to be? (ie, logout)", :cyan
      devise_sign_up_route = ask "What would you like your Devise Sign Up route to be? (ie, signup)", :cyan
      devise_edit_route = ask "What would you like your Devise Edit Registrations route to be? (ie, settings)", :cyan
      # Add routes to routes.rb
      routes_text = File.read("config/routes.rb")
      routes_text = routes_text.gsub("devise_for :#{devise_model}s",
%Q{devise_for :users, :path_names => { :sign_in => '#{devise_sign_in_route}', :sign_out => '#{devise_sign_out_route}', :sign_up => '#{devise_sign_up_route}' } do # Customise Devise /users/:actions
    get '#{devise_sign_up_route}', :to => 'registrations#new'
    get '#{devise_sign_in_route}', :to => 'devise/sessions#new'
    get '#{devise_sign_out_route}', :to => 'devise/sessions#destroy'
    get '#{devise_edit_route}', :to => 'registrations#edit'
  end
})
      File.delete("config/routes.rb")
      File.open("config/routes.rb", "w+").write(routes_text)
      # Commit changes
      system "git add ."
      system "git commit -a -m \"Added custom Devise routes.\" -q"
    end
    
    # => Copy Devise views
    if yes? "Would you like to add Devise views to your app? (y/n)", :cyan
      template_engine = ask? "Which template engine would you like to use to generate your Devise views? (haml/erb/slim)", :cyan  # !!! CHANGE TO GLOBAL OPTION LATER
      # !!! CHECK IF HAML IS INSTALLED
      if template_engine == "haml" || template_engine == "slim"
        say "Installing gems required to generate views..."
        gemfile = File.open("Gemfile", "a")
        gemfile.write(
%Q{
gem 'hpricot'                   # => For generating HAML Devise views - http://github.com/hpricot/hpricot
gem 'ruby_parser'               # => For generating HAML Devise views
})
        system "bundle install --quiet"
        say "Gems all installed!", :green
      end
      say "Generating Devise views in #{template_engine}..."
      system "rails generate devise:views --template-engine=#{template_engine.downcase} -q"
      say "Devise views have been generated!", :green
      system "git add ."
      system "git commit -a -m \"Generated Devise views in #{template_engine}.\" -q"
    end
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # omniauth - Set up Omniauth social authentication                                                    #
  # --------------------------------------------------------------------------------------------------- #
  desc "omniauth", "Add external authentication for Devise through Omniauth."
  def omniauth
    if yes? "Would you like use Omniauth with Devise for external authentication? This will only work for a model named 'User'! (y/n) ", :red
      
      # => Add Omniauth gem to Gemfile
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem 'omniauth'                    # => Allows the use of external authentications - http://github.com/intridea/omniauth")
      File.delete("Gemfile")
      File.open("Gemfile", "+w").write(gemfile)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth to Gemfile.\" -q"
      say "Added OmniAuth to Gemfile", :green
      
      # => Set external auth parameters
      if facebook = yes?("Would you like to use Facebook as an external authentication provider? (y/n) ", :cyan)
        facebook_app_id = ask "What is your Facebook App ID?", :yellow
        facebook_app_secret = ask "What is your Facebook App secret?", :yellow
        facebook_scope = ask "What scope will your app require? (email, publish_stream, offline_access)", :yellow
      end
      if twitter = yes?("Would you like to use Twitter as an external authentication provider? (y/n) ", :cyan)
        twitter_app_id = ask "What is your Twitter App ID?", :yellow
        twitter_app_secret = ask "What is your Twitter App secret?", :yellow
      end
      if linked_in = yes?("Would you like to use LinkedIn as an external authentication provider? (y/n) ", :cyan)
        linked_in_app_id = ask "What is your LinkedIn App ID?", :yellow
        linked_in_app_secret = ask "What is your LinkedIn App secret?", :yellow
      end
      
      # => Write options to Devise initializer
      devise_config = File.read("config/initializers/devise.rb")
      devise_config = devise_config.gsub("# ==> OmniAuth",
%Q{# ==> OmniAuth
#{"  config.omniauth :facebook, \"#{facebook_app_id}\", \"#{facebook_app_secret}\", :scope => \"#{facebook_scope}\"" if facebook}
#{"  config.omniauth :twitter, \"#{twitter_app_id}\", \"#{twitter_app_secret}\""if twitter}
#{"  config.omniauth :linked_in, \"#{linked_in_app_id}\", \"#{linked_in_app_secret}\"" if linked_in}})
      File.delete("config/initializers/devise.rb")
      File.open("config/initializers/devise.rb", "w+").write(devise_config)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth config to Devise initializer.\" -q"
      say "Added OmniAuth config to Devise initializer.", :green
      
      # => Make Devise model Omniauthable
      say "Applying OmniAuthable to the User model.", :cyan
      devise_omniauthable = File.read("app/models/user.rb")
      devise_omniauthable = devise_model.gsub(":validatable", ":validatable, :omniauthable"
      File.delete("app/models/user.rb")
      File.open("app/models/user.rb", "w+").write(devise_omniauthable)
      system "git add ."
      system "git commit -a -m \"Made User omniauthable for OmniAuth through Devise.\" -q"
      say "Made User omniauthable for OmniAuth through Devise.", :green
      
      # => Create Authentication model
      say "Creating Authentication model to store external authentications."
      system "rails generate model Authentication user_id:integer provider:string uid:string token:string"
      File.delete("app/models/authentication.rb")
      File.open("app/models/authentication.rb", "w+").write(
%Q{class Authentication < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user

  # SCOPES
  scope :facebook, where(:provider => "facebook")
  scope :twitter, where(:provider => "twitter")
  scope :linkedin, where(:provider => "linked_in")

end})
      system "git add ."
      system "git commit -a -m \"Added Authentication model for OmniAuth authentications.\" -q"
      say "Added Authentication model for OmniAuth authentications.", :green
      
      # => Create Authentications controller
      say "Creating Authentications controller..."
      system "rails generate controller Authentications"
      File.delete("app/controllers/authentications_controller.rb")
      File.open("app/controllers/authentications_controller.rb", "w+").write(
%q{class AuthenticationsController < Devise::OmniauthCallbacksController

  # CAPTURES ALL POSSIBLE OMNIAUTH PROVIDOR METHODS - As Omniauth requires a providor method - method missing captures it.
  def method_missing(provider)
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Welcome back! You're all signed in."
      sign_in_and_redirect(:user, authentication.user)
    elsif signed_in_resource
      signed_in_resource.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => (omniauth['credentials']['token'] rescue nil))
      redirect_to root_path, :notice => "Successfully added #{omniauth['provider'].camelcase} to your profile!"
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Welcome! You just connected via #{omniauth['provider'].camelcase}."
        sign_in_and_redirect(:user, user)
      else
        if omniauth['provider'] == "twitter"
          session["devise.omniauth"] = omniauth.except('extra')
        else
          session["devise.omniauth"] = omniauth
        end
        redirect_to new_user_registration_path
      end
    end
  end

  # DESTROY OMNIAUTH SESSION
  def destroy_session
    session.delete("devise.omniauth")
    redirect_to new_user_registration_path
  end

end})
      system "git add ."
      system "git commit -a -m \"Added Authentication controller for handling OmniAuth authentications.\" -q"
      say "Added Authentication controller for handling OmniAuth authentications.", :green
      
      # => Create Registrations controller to handle registrations through OmniAuth
      say "Creating Registrations controller..."
      File.open("app/controllers/registrations_controller.rb", "w+").write(
%q{class RegistrationsController < Devise::RegistrationsController

  private

  def build_resource(*args)
    super
    if omniauth          = session['devise.omniauth']
      # APPLY OMNIAUTH AUTRIBUTES
      @user.apply_omniauth(omniauth)
      # FACEBOOK ATTRIBUTES
      if omniauth['provider'] == "facebook"
        #@user.first_name = omniauth['user_info']['first_name']
        #@user.last_name  = omniauth['user_info']['last_name']
      # TWITTER ATTRIBUTES
      elsif omniauth['provider'] == "twitter"
        #full_name        = omniauth['user_info']['name']
        #@user.first_name = full_name.split.first
        #@user.last_name  = full_name.split.last
        #@user.bio        = omniauth['user_info']['description']
      end
    end
  end

  # REDIRECT ON PROFILE EDIT - https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
  def after_update_path_for(resource)
    user_path(resource)
  end

end})
      system "git add ."
      system "git commit -a -m \"Added Registrations controller for handling new registrations through OmniAuth authentications.\" -q"
      say "Added Registrations controller for handling new registrations through OmniAuth authentications.", :green
      
      # => Add methods to the User model
      user_model = File.read("app/models/user.rb")
      user_model = user_model.gsub("class User < ActiveRecord::Base",
%Q{class User < ActiveRecord::Base
  
  # CALLBACKS
  before_destroy :destroy_authentications # Destroys any associated authentications})
      user_model = user_model.gsub("end", 
%Q{  # OMNIAUTH METHODS
  def password_required? # Password isn't required if authenticating externally
    (authentications.empty? || !password.blank?) && super
  end

  def update_with_password(params={}) # Users don't have to enter their current password to update their profile
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end

  def apply_omniauth(omniauth) # Build the authentication of the user
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => (omniauth['credentials']['token'] rescue nil))
  end

  def has_auth(auth_provider)
    authentications.find_by_provider(auth_provider)
  end

  # PRIVATE METHODS
  private
  
    def destroy_authentications # Destroys the authentications of a user on delete
      @authentications = Authentication.find_all_by_user_id(self.id)
      @authentications.each do |authentication|
        authentication.destroy
      end
    end

end})
      
      File.delete("app/models/user.rb")
      File.open("app/models/user.rb", "w+").write(user_model)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth methods to User model.\" -q"
      say "Added OmniAuth methods to User model.", :green
      
      # => Add new controllers to Devise routes
      say "Adding new controllers to Devise routes..."
      omniauth_routes = File.read("config/routes.rb")
      omniauth_routes = omniauth_routes.gsub("devise_for :users", "devise_for :users, :controllers => { :registrations => \"registrations\", :omniauth_callbacks => \"authentications\"")
      File.delete("config/routes.rb")
      File.open("config/routes.rb", "w+").write(omniauth_routes)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth methods to User model.\" -q"
      say "Added controllers required for OmniAuth authentications.", :green
      
      # => Finished! *phew*
      say "OmniAuth authentication has been added to the User model!", :green
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # pivotal - Set up Pivotal Tracker project                                                            #
  # --------------------------------------------------------------------------------------------------- #
  desc "pivotal", "Add Pivotal Tracker support through the Pickler gem."
  def pivotal
    if yes? "Would you like to setup Pivotal Tracker support through the Pickler gem? (y/n) ", :cyan
      gemfile = File.open("Gemfile", "a")
      gemfile.write(
%Q{
group :development do
  gem 'pickler'
end})
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # capistrano - Set up deploy.rb for Capistrano deployment                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "capistrano", "Add Capistrano support for easy deployment."
  def capistrano
    # => !!! Capistrano code here
    # => !!! Nginx support
    # => !!! Whenever cron tab stuff
    # => !!! Delayed_job stuff
    # => !!! 
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # forms - Use formtastic for semantic webforms                                                        #
  # --------------------------------------------------------------------------------------------------- #
  desc "forms", "Adds Formtastic support for semantic web forms."
  def forms
    if yes? "Would you like to use Formtastic for semantic web form? (y/n) ", :cyan
      # => Add Formtastic to Gemfile
      gemfile = File.open("Gemfile", "a")
      gemfile.write("gem 'formtastic'                  # => For sexy forms - http://github.com/justinfrench/formtastic")
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Added Formtastic for semantic web forms.\" -q"
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # github - Set up remote repository and push                                                          #
  # --------------------------------------------------------------------------------------------------- #
  desc "github", "Add remote GitHub repository to app and push."
  def github
    if yes? "Does the app have a GitHub repository? (y/n) ", :cyan
      github_username = ask "What is your GitHub username? ", :yellow
      github_repository = ask "What is the repository name? ", :yellow
      github_path = "git@github.com:#{github_username}/#{github_repository}.git"
      # Add remote repository
      system "git remote add origin #{github_path}"
      say "Added remote origin at #{github_path}"
      # Push to remote repository
      if yes? "Would you like to push to #{github_path}? (y/n) ", :cyan
        say "Pushing to master at #{github_path}..."
        system "git push origin master"
        say "Your app has been pushed!", :green
      end
    end
  end
  
end