#ruby-web-sms-chat

Ruby backend for web-based chat application that features Catapult SMS and MMS capabilities.

Demos uses of the:
* [Catapult Ruby SDK](https://github.com/bandwidthcom/ruby-bandwidth)
* [Creating Application](http://ap.bandwidth.com/docs/rest-api/applications/?utm_medium=social&utm_source=github&utm_campaign=dtolb&utm_content=_)
* [Searching for Phone Number](http://ap.bandwidth.com/docs/rest-api/available-numbers/#resourceGETv1availableNumberslocal/?utm_medium=social&utm_source=github&utm_campaign=dtolb&utm_content=_)
* [Ordering Phone Number](http://ap.bandwidth.com/docs/rest-api/phonenumbers/#resourcePOSTv1usersuserIdphoneNumbers/?utm_medium=social&utm_source=github&utm_campaign=dtolb&utm_content=_)
* [Messaging REST Api Callbacks](http://ap.bandwidth.com/docs/callback-events/text-messages-sms/?utm_medium=social&utm_source=github&utm_campaign=dtolb&utm_content=_)

## Prerequisites
- Configured Machine with Ngrok/Port Forwarding -OR- Heroku Account
  - [Ngrok](https://ngrok.com/)
  - [Heroku](https://www.heroku.com/)
- [Ruby 2.2+](https://www.ruby-lang.org/en/downloads/)

## Deploy To PaaS

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


## Install on Local Machine

```bash
# clone the app with submodules

git clone git@github.com:BandwidthExamples/ruby-web-sms-chat.git

# install dependencies

bundle install

# run the app

cd ..

PORT=3000 ruby app.rb # or `bundle exec puma -p 3000`

```

Run in another terminal

```bash
ngrok http 3000 #to make ngrok to open external access to localhost:3000 
```

Open in browser your external url (it will be shown by ngrok).

## Deploy on Heroku Manually

Create account on [Heroku](https://www.heroku.com/) and install [Heroku Toolbel](https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up) if need.

Run `heroku create` to create new app on Heroku and link it with current project.

Run `git push heroku master` to deploy this project.

Run `heroku open` to see home page of the app in the browser
