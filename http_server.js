const express = require('express');
const server = express();
const { body, validationResult } = require('express-validator');
var bodyParser = require('body-parser');
var jsonParser = bodyParser.json();
var urlEncodedParser = bodyParser.urlencoded({extended: false});


server.post("/signup_url/",
    urlEncodedParser,
    body('fname').trim().isLength({ min: 1}).withMessage("First Name is Empty"),
    body('lname', 'Empty last name').trim().isLength({ min: 1}).escape(),
    body('email', 'Invalid email address').isEmail(),
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            console.log(req.body);
            return res.status(400).json({ errors: errors.array() });
        }

        console.log(req.body);
        return res.status(200);

});

server.get("/json", (req, res) => {
    res.json({message: "hello world"});
});

server.get("/", (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

server.get("/about", (req, res) => {
    res.sendFile(__dirname + '/public/about.html')
})

const port = 4000;

server.listen(port, () => {
    console.log(`Server is listening at ${port}`);
});