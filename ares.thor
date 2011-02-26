# ARES
class Ares < Thor
  
  # VARIABLES
  RED = "\e[31m"
  YELLOW = "\e[33m"
  GREEN = "\e[32m"
  CYAN = "\e[36m"
  MAGENTA = "\e[35m"
  
  DEFAULT_FILES = ["public/index.html", "public/images/rails.png"]
  
  # --------------------------------------------------------------------------------------------------- #
  # new - Create a new app                                                                              #
  # --------------------------------------------------------------------------------------------------- #
  desc "new", "Create a new Rails app."
  def new
    
    # => Name the app...
    say("Creating a new Rails app using Ares...")
    app_name = ask("What would you like your app to be named? ", CYAN).downcase
    app_name = app_name.gsub!(/[^a-z0-9\-_]+/, "_") if app_name.include? " "
    
    # => Create the app and change directory
    say("Creating the Rails app #{app_name}.")
    system("rails new #{app_name} -q")
    Dir.chdir(app_name)
    app_directory = Dir.pwd
    
    # => Initialize the Git repository
    say("Initializing a Git repository for #{app_name}.")
    system("git init -q")
    
    # => Add .gitignore
    say("Adding .gitignore file.")
    gitignore = File.new(".gitignore", "r+")
    gitignore.syswrite(".bundle\ndb/*.sqlite3\nlog/*.log\nlog/*.pid\ntmp/**/*\ntest\npublic/uploads\n")
    
    # => Initial commit
    system("git add .")
    system("git commit -a -m \"Initial commit.\" -q")
    say("Rails app created and Git repository initialized in #{app_directory}", GREEN)
    
    # => Invoke other tasks!
    invoke :default_files
    invoke :jquery
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
    if yes?("Remove the default Rails files and README? (yes/no) ", CYAN)
      DEFAULT_FILES.each do |file|
        File.delete(file)
        say("Deleted the file #{file}")
      end
      File.open("README", "w").write("")
      say("Reset README to be blank.")
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Removed default Rails files and README.\" -q")
      say("Default Rails files and README have been deleted!", GREEN)
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # jquery - Set jQuery as the default javascript framework                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "jquery", "Set jQuery as the default javascript framework instead of Prototype."
  def jquery
    if yes?("Would you like to use jQuery instead of Prototype? (yes/no) ", CYAN)
      jquery_ui = yes?("Would you like to install jQuery UI as well? (yes/no) ", YELLOW) ? true : false
      # Remove Prototype files
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite("gem \"jquery-rails\"")
      say("Adding jquery-rails gem to Gemfile and running bundle update...")
      system("bundle install --quiet")
      system("rails generate jquery:install #{"--ui" if jquery_ui == true}")
      say("Installed jQuery#{" & jQuery UI" if jquery_ui == true} as default javascript framework.", GREEN)
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Installed jQuery as default javascript framework.\" -q")    
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # forms - Use formtastic for semantic webforms                                                        #
  # --------------------------------------------------------------------------------------------------- #
  desc "forms", "Adds Formtastic support for semantic web forms."
  def forms
    if yes?("Would you like to use Formtastic for semantic web form? (yes/no) ", CYAN)
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite("gem \"formtastic\"")
      # => Commit changes
      system("git add .")
      system("git commit -a -m \"Added Formtastic for semantic web forms.\" -q")    
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # testing - Set up Testing Framworks                                                                  #
  # --------------------------------------------------------------------------------------------------- #
  desc "testing", "Sets up testing frameworks for your app."
  def testing
    cucumber = yes?("Would you like to use Cucumber for integration testing? (yes/no) ", CYAN) ? true : false
    rspec = yes?("Would you like to use RSpec for unit testing? (yes/no) ", CYAN) ? true : false
    seed = yes?("Would you like to seed test data in your tests? [Adds machinist and faker gems] (yes/no) ", CYAN) ? true : false
    fakeweb = yes?("Would you like to block HTTP requests in your tests? [Adds fakeweb gem] (yes/no) ", CYAN) ? true : false
    if cucumber
      capybara = yes?("Would you like to use Capybara for interactions with Cucumber? (yes/no) ", CYAN) ? true : false
      email_spec = yes?("Would you like to test the sending / receipt of emails in your Cucumber tests? [Adds email_spec gem and steps] (yes/no) ", CYAN) ? true : false
    end
    if cucumber || rspec
      # => Add required gems to Gemfile
      say("Adding testing / development gems to Gemfile..")
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite(
%Q{
# TESTING / DEVELOPMENT GEMS
group :development, :test do
#{"gem 'cucumber'
  gem 'cucumber-rails'            # => Rails generators for Cucumber - http://github.com/aslakhellesoy/cucumber-rails" if cucumber}
#{"  gem 'capybara'                  # => Rails testing driver - http://github.com/jnicklas/capybara" if capybara}
#{"  gem 'rspec'                     # => Behaviour driven development for ruby - http://github.com/rspec/rspec
  gem 'rspec-rails'               # => RSpec extension library for Ruby on Rails - http://github.com/rspec/rspec-rails" if rspec}
  gem 'database_cleaner'          # => For cleaning database between test sessions - http://github.com/bmabey/database_cleaner
  gem 'spork'                     # => DRb server for testing frameworks - http://github.com/timcharper/spork
  gem 'launchy'                   # => Helper class for launching applications - http://copiousfreetime.rubyforge.org/launchy/
#{"  gem 'machinist'                 # => For creating seed data / database population - http://github.com/notahat/machinist
  gem 'faker'                     # => For generating random data - http://faker.rubyforge.org/" if seed}
#{"  gem 'fakeweb'                   # => For blocking external HTTP access in tests - http://github.com/chrisk/fakeweb" if fakeweb}
#{"  gem 'email_spec'                # => For testing ActionMailer in Cucumber - http://github.com/bmabey/email-spec" if email_spec}
end
})
      # => Bundle update to install gems and commit changes
      say("Running bundle install...")
      system("bundle install --quiet")
      system("git add .")
      system("git commit -a -m \"Added testing gems to Gemfile.\" -q")
      
      # => Install RSpec
      if rspec
        say("Installing RSpec...")
        system("rails generate rspec:install --quiet")
        say("RSpec installed!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added RSpec for unit testing.\" -q")
      end
      
      # => Run Cucumber generator
      if cucumber
        say("Installing Cucumber...")
        system("rails generate cucumber:install#{" --capybara" if capybara == true}#{" --rspec" if rspec == true} --quiet")
        say("Cucumber installed!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added Cucumber for integration testing.\" -q")
      end
      
      # => Run email_spec generator commands
      if email_spec
        say("Installing Cucumber email steps...")
        system("rails generate email_spec:steps --quiet")
        say("Cucumber email steps installed to features/step_definitions/email_steps.rb!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added email_spec test steps for testing emails with Cucumber.\" -q")
      end
      
      # => Installing Fakeweb
      if fakeweb
        say("Installing Fakeweb...")
        fakeweb_file = File.new("features/support/fakeweb.rb", "w+")
        fakeweb_file.syswrite("# Fakeweb URI definitions\nFakeWeb.allow_net_connect = false # Doesn't allow testing to connect to the internet")
        say("Fakeweb installed with config in features/support/fakeweb.rb!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added Fakeweb for blocking HTTP requests in tests.\" -q")
      end
      
      # => Success notice
      say("Test suite successfully installed!", GREEN)
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # devise - Set up Devise authentication                                                               #
  # --------------------------------------------------------------------------------------------------- #
  desc "devise", "Add User authentication with Devise."
  def devise
    
    # => Add Devise gem to Gemfile
    say("Adding Devise gem to Gemfile...")
    gemfile = File.open("Gemfile", "a")
    gemfile.syswrite("\ngem 'devise'                      # => For user authentication - http://github.com/plataformatec/devise")
    say("Running bundle install...")
    system("bundle install --quiet")
    system("git add .")
    system("git commit -a -m \"Added Devise to Gemfile.\" -q")
    
    # => Install Devise
    say("Installing Devise...")
    system("rails generate devise:install")
    say("Devise is installed!", GREEN)
    system("git add .")
    system("git commit -a -m \"Installed Devise for authentication.\" -q")
    
    # => Add devise model
    devise_model = yes?("What would you like to name your Devise model? (User, Admin, etc) ", CYAN).downcase
    devise_model = devise_model.gsub!(/[^a-z0-9\-_]+/, "_") if devise_model.include? " "
    say("Generating the Devise model...")
    system("rails generate devise #{devise_model} -q")
    say("Devise model for #{devise_model} generated!", GREEN)
    system("git add .")
    system("git commit -a -m \"Added #{devise_model} model for Devise authentication.\" -q")
    
    # => Add custom Devise routes
    if yes?("Would you like to Ad some custom routes for your Devise model? (yes/no)", CYAN)
      # Define routes to use
      devise_sign_in_route = ask?("What would you like your Devise Sign In route to be? (ie, login)", CYAN)
      devise_sign_out_route = ask?("What would you like your Devise Sign Out route to be? (ie, logout)", CYAN)
      devise_sign_up_route = ask?("What would you like your Devise Sign Up route to be? (ie, signup)", CYAN)
      # Add routes to routes.rb
      routes = File.open("config/routes.rb", "a")
      routes.syswrite(
%Q{
  devise_for :users, :path_names => { :sign_in => '#{devise_sign_in_route}', :sign_out => '#{devise_sign_out_route}', :sign_up => '#{devise_sign_up_route}' } do # Customise Devise /users/:actions
    get '#{devise_sign_up_route}', :to => 'registrations#new'
    get '#{devise_sign_in_route}', :to => 'devise/sessions#new'
    get '#{devise_sign_out_route}', :to => 'devise/sessions#destroy'
    get 'settings', :to => 'registrations#edit'
  end
})
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Added custom Devise routes.\" -q")
    end
    
    # => Copy Devise views
    if yes?("Would you like to add Devise views to your app? (yes/no)", CYAN)
      template_engine = ask?("Which template engine would you like to use to generate your Devise views? (haml/erb/slim)", CYAN)  # !!! CHANGE TO GLOBAL OPTION LATER
      # CHECK IF HAML IS INSTALLED
      if template_engine == "haml" || template_engine == "slim"
        say("Installing gems required to generate views...")
        gemfile = File.open("Gemfile", "a")
        gemfile.syswrite(
%Q{
gem 'hpricot'                   # => For generating HAML Devise views - http://github.com/hpricot/hpricot
gem 'ruby_parser'               # => For generating HAML Devise views
})
        system("bundle install --quiet")
        say("Gems all installed!", GREEN)
      end
      say("Generating Devise views in #{template_engine}...")
      system("rails generate devise:views --template-engine=#{template_engine.downcase} -q")
      say("Devise views have been generated!", GREEN)
      system("git add .")
      system("git commit -a -m \"Generated Devise views in #{template_engine}.\" -q")
    end
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # omniauth - Set up Omniauth social authentication                                                    #
  # --------------------------------------------------------------------------------------------------- #
  desc "omniatuh", "Add Pivotal Tracker support through the Pickler gem."
  def omniauth
    
    # => Add Omniauth gem to Gemfile
    gemfile = File.open("Gemfile", "a")
    gemfile.syswrite(
%Q{
group :development do
  gem 'omniauth'
})
  end


  
  # --------------------------------------------------------------------------------------------------- #
  # pivotal - Set up Pivotal Tracker project                                                            #
  # --------------------------------------------------------------------------------------------------- #
  desc "pivotal", "Add Pivotal Tracker support through the Pickler gem."
  def pivotal
    gemfile = File.open("Gemfile", "a")
    gemfile.syswrite(
%Q{
group :development do
  gem 'pickler'
})
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # github - Set up remote repository and push                                                          #
  # --------------------------------------------------------------------------------------------------- #
  desc "github", "Add remote GitHub repository to app and push."
  def github
    if yes?("Does the app have a GitHub repository? (yes/no) ", CYAN)
      github_username = ask("What is your GitHub username? ", YELLOW)
      github_repository = ask("What is the repository name? ", YELLOW)
      github_path = "git@github.com:#{github_username}/#{github_repository}.git"
      # Add remote repository
      system("git remote add origin #{github_path}")
      # Push to remote repository
      if yes?("Would you like to push to #{github_path}? (yes/no) ")
        say("Pushing to master at #{github_path}...")
        system("git push origin master")
        say("Your app has been pushed!", GREEN)
     end
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # capistrano - Set up deploy.rb for Capistrano deployment                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "capistrano", "Add Capistrano support for easy deployment."
  def capistrano
    # => Capistrano code here
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # home - Set up Home controller                                                                       #
  # --------------------------------------------------------------------------------------------------- #
  desc "home", "Add Home controller for Home page."
  def home
    if yes?("Would you like to create a Home Page controller for your app? (yes/no) ", CYAN)
      # Name the root controller
      root_controller_name = ask?("What would you like to name your Home Page controller?", CYAN)
      root_controller_name = root_controller_name.gsub!(/[^a-z0-9\-_]+/, "_") if root_controller_name.include? " "
      # Generate the controller
      say("Creating the controller \"#{root_controller_name}\"...")
      system("rails generate controller #{root_controller_name} index --template-engine=haml") # !!! CHANGE TO GLOBAL OPTION LATER
      # Add root route to routes.rb
    end
  end
  
  
end
