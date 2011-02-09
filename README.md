# Ares

## What is Ares?

Ares is a toolkit for Rails developers that makes creating new apps with complex functionality from the get go super easy.

Ares is built of Yehuda Katz's awesome Rake like utility, [Thor](http://github.com/wycats/thor).

## What does Ares do?

Ares makes making Rails apps super easy, it does this by doing most of the boring stuff for you, including:

1. Creates your Rails app
2. Initializes a Git repository and initial commit.
3. Adds a .gitignore file
4. Removes the default Rails files (index.html, etc)
5. Installs jQuery and removes Prototype as the default javascript framework (with jQuery rails.js)
6. Sets up the testing frameworks of your choice (Cucumber, RSpec, etc) and configures
7. Sets up a remote GitHub repository and pushes to origin master

All with clean commits between each step if you ever change your mind!

## Using Ares

As Ares is a set of Thor tasks, you will have to have the Thor gem installed to use Ares.
  
    gem install thor

### Installing Ares

As Thor allows the install of tasks, to be able to use Ares anywhere you should install it. You can install Ares by running:

    thor install https://github.com/infinityrobot/ares/raw/master/ares.thor

Now no matter which directory you are in, you will be able to use Ares.

### Creating a new Rails app

Creating a new Rails app with Ares is super easy, just run <tt> thor ares:new </tt> and follow the prompts!

## Commands

The full list of Ares commands:

* ares:new
* ares:default_files
* ares:jquery
* ares:testing
* ares:github
* ares:rename

## Tools Used

In order to do what Ares does there is a number of tools that are used:

* [Thor](http://github.com/wycats/thor): The scripting framework Ares is built on
* [Devise](http://github.com/plataformatec/devise): Devise gem for user authentication.
* [OmniAuth](http://github.com/intridea/omniauth): OmniAuth gem for external authentications.
* [Cucumber](http://github.com/aslakhellesoy/cucumber-rails): Cucumber for integration testing.
* [RSpec](http://github.com/rspec/rspec-rails): RSpec for unit testing.
* [Machinist](http://github.com/notahat/machinist) & [Faker](http://faker.rubyforge.org/): For populating test database with seed data.
* [Fakeweb](http://github.com/chrisk/fakeweb): Blocks HTTP requests during tests (great for stubbing out Google Maps requests in tests!)
* [email_spec](http://github.com/bmabey/email-spec): Allows testing of emails in Cucumber.
* [jquery-rails](http://github.com/indirect/jquery-rails): The gem used to install jQuery as the default javascript framework.
* [Markdown](http://daringfireball.net/projects/markdown/): Markdown for this README.

Thanks a million to all of the developers that have worked on these tools and made them what they are, I would not survive without them!

## Links

Want to start developing your own Thor tasks? Here are some awesome links which helped me a heap.

* [Thor Github repository](http://github.com/wycats/thor)
* [Interactive prompts with Thor](http://stackoverflow.com/questions/4604905/interactive-prompt-with-thor)
* [Calling command line tools inside a Thor script](http://stackoverflow.com/questions/4801920/is-it-possible-to-call-git-or-other-command-line-tools-from-inside-a-thor-script)
