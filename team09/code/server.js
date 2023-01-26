const cookieParser = require('cookie-parser');
const { response } = require('express');
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

var urlencodedParser = bodyParser.urlencoded({ extended: false })
var emails;
global.emails;
global.name;
// Google Auth
const {OAuth2Client} = require('google-auth-library');
const CLIENT_ID = '70929119722-q421bkdo1ii9bsnk3f597u13tr67dp6v.apps.googleusercontent.com'
const client = new OAuth2Client(CLIENT_ID);

const PORT = process.env.PORT || 7000;

// Middleware
app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser());
app.use(express.static('public'));
app.use('/static', express.static('public'));

// Database Connection
const mysql = require('mysql');
const connection = mysql.createConnection({
    host    : 'team-09-db-vm0.service.consul',
    user    : 'itmt430',
    password: 'team09w',
    database: 'itmt430'
});

app.get('/', (req, res) => {
    console.log("Entering welcome page");
    res.render('index');
});

app.get('/login', (req, res) => {
    console.log("Entering login page");
    res.render('login');
});

app.post('/login', (req, res) => {
    let token = req.body.token;

    //console.log(token);
    async function verify() {
        const ticket = await client.verifyIdToken({
            idToken: token,
            audience: CLIENT_ID,  // Specify the CLIENT_ID of the app that accesses the backend
            // Or, if multiple clients access the backend:
            //[CLIENT_ID_1, CLIENT_ID_2, CLIENT_ID_3]
        });
        const payload = ticket.getPayload();
        const userid = payload['sub'];
        // If request specified a G Suite domain:
        // const domain = payload['hd'];
        //console.log(payload);
    }

    verify()
    .then(() => {
        res.cookie('session-token', token );
        res.send('success');
    }).catch(console.error);
  
});

app.get('/dashboard', checkAuthenticated, (req, res) => {
    let user = req.user;
    res.render('dashboard', {user});
});

app.get('/logout', (req, res) => {
    res.clearCookie('session-token');
    console.log("Clearing Cookie");
    res.redirect('/');
});

app.get('/about-us', (req, res) => {
    console.log("Entering about us page");
    res.render('about-us');
});

app.get('/explore', (req, res) => {
    console.log("Entering explore page");
    res.render('explore');
});

app.get('/companies', (req, res) => {
    console.log("Entering companies page");
    res.render('companies');
});

app.get('/events', (req, res) => {
    console.log("Entering events page");
    res.render('events');
});

app.get('/charity', (req, res) => {
    console.log("Entering charity page");
    res.render('charity');
});

app.get('/questions', (req, res) => {
    console.log("Entering questions page");
    res.render('questions');
});

app.get('/user-account', (req, res) => {
    res.render('user-account');
});

app.post('/user-account', urlencodedParser, (req, res) => {
    if(!req.body) return res.sendStatus(400);
    const fullname = req.body.fullname;
    const phonenumber = req.body.phonenumber;
    const country = req.body.country;
    const address1 = req.body.address1;
    const address2 = req.body.address2;
    const fulladdress = address1 + "," + address2;
    const city = req.body.city;
    const state = req.body.state;
    const zipcode = req.body.zip;
    const occupation = req.body.occupation;
    const email = global.emails;

    const update = `UPDATE accounts SET 
    name = '${fullname}',
    phone = '${phonenumber}',
    country = '${country}',
    address = '${fulladdress}', 
    city = '${city}', 
    state = '${state}',
    zipcode = '${zipcode}',
    occupation = '${occupation}'
    WHERE email = '${email}'`;

    if(email == "undefined") {
        res.redirect('/login');
    } else{
        connection.query(update, (err, result) => {
            if(err) throw err;
            console.log(`${email} has been updated`);
            res.redirect('/dashboard');
        });
    }
});

// NOTES:
// If you want to add another page, put it above this file
// or, the pages will gives you 404 error
// REMINDER! positions matter in this problem
app.all('*', (req, res) => {
    console.log("Entering errors page");
    res.status(404).render('errors');
    res.status(403).render('errors');
    //res.status(404).send('<h1>404! Page not found GO BACK!</h1>');
});

function checkAuthenticated(req, res, next){
    let token = req.cookies['session-token'];

    let user = {};
    async function verify() {
        const ticket = await client.verifyIdToken({
            idToken: token,
            audience: CLIENT_ID, // Specify the CLIENT_ID of the app that accesses the backend
        });

        const payload = ticket.getPayload();
        user.name = payload.name;
        user.email = payload.email;
        user.picture = payload.picture;
        user.hd = payload.hd;
        // Sent the user.email to global.email
        global.emails = user.email;
        global.name = user.name;
        // Create a database connection
        // check if user.hd is exist
        if(user.hd) {
            // Check if row exists
            var exists = `SELECT * FROM accounts WHERE (email='${user.email}')`;
            connection.query(exists, function(err, result) {
                if(err) {
                    throw err;
                } else {
                    if(result && result.length) {
                        return;
                    } else {
                        var account = `INSERT INTO accounts (name, email) values('${user.name}','${user.email}')`;
                        connection.query(account, function(err, result) {
                            if(err) throw err;
                            console.log("1 Data inserted");
                        });
                    }
                }
            });
        } else {
            console.log('Please use Hawk email for sign in!');
            response.send('Please use Hawk email for sign in!');
            response.end();
        }
    }
    verify()
    .then(() => {
        req.user = user;
        next();
    })
    .catch(err => {
        res.redirect('/login');
    });
}

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});