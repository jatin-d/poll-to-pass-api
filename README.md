Welcome to Poll To Pass!
===================

**Poll to Pass** is a web-based platform to post your polls, any question that baffles you to make decisions.  You can crowdsource solutions for your questions. you can get people to vote on it and at the end of the specific time, you can see the outcome.

----------

Non-LoggedIn functionalities
-------------
The application works in two ways, by signing up and log in or without signing up. If you are not signed up / logged in, you will be able to see the SignUp and LogIn option in the header. 

**Home**
![enter image description here](https://i.imgur.com/uG5Rwnt.png)

If you are only browsing live polls, you do not require to log in. You will be able to see live polls on the home page and also can browse the results of all available polls. If you try to take a poll without signing in, the app will prompt you to sign in to take the poll.

**Poll Result**
![enter image description here](https://i.imgur.com/yKzCgoO.png)

----------

LoggedIn functionalities
-------------

Once you sign up and logged In, you will be able to...
>- Take the poll,
>- Create a poll,
>- Create a profile that shows all polls created by you,
>- Edit your profile and
>- Edit your polls.

**Profile**
![enter image description here](https://i.imgur.com/Mu6DOsN.png)

**New Poll**
![enter image description here](https://i.imgur.com/ML2sR18.png)

After logging in, the interface changes and does not show options for logging in or signing up. Instead, it shows options to enter New Poll, visit your Profile, or Log Out. On the extreme right side of the header, it shows the username of the person logged In.

**Home -- Logged In**
![enter image description here](https://i.imgur.com/B3pbJuC.png)

----------


Development
-------------
The game is developed using HTML5, and CSS for front-end programming and Ruby with Sinatra for the back-end. HTML is used to render the game on a browser. Game styles are created using CSS. The application data is stored in a database which is created using PostgreSQL. This application is developed to practice CRUD operations which stands for Create, Read, Update and Delete operations in the database.

> **Development Features:**

> - For each functionality on the page, a route is created on Ruby, Local Host Server was used while development and testing. The server was run by using the Sinatra framework.
> - While visiting different routes, queries are sent to PSQL to send or receive data. The data is then transformed into a desirable form using Ruby and rendered on the browser using .erb files. To take care of minor programming on client-side, templating is used.
> - Fully functional app was then deployed on the Heroku platform.

Demo
-------------
[Check out Poll-To-Pass](https://poll-to-pass-api.herokuapp.com/)