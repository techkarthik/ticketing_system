const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');

const Otp = require('../models/Otp');

const nodemailer = require('nodemailer');

// Send OTP
router.post('/send-otp', async (req, res) => {
    try {
        const { email } = req.body;

        // Basic email validation
        // Using a simple regex or check
        if (!email || !email.includes('@')) {
            return res.status(400).json({ message: 'Invalid email address' });
        }

        const existingUser = await User.findOne({ username: email });
        if (existingUser) {
            return res.status(400).json({ message: 'Email already registered. Please login.' });
        }

        // Generate 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Save to DB
        const newOtp = new Otp({ email, otp });
        await newOtp.save();

        // Send Email
        const transporter = nodemailer.createTransport({
            host: process.env.SMTP_HOST,
            port: process.env.SMTP_PORT,
            secure: false, // true for 465, false for other ports
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASS
            },
            tls: {
                rejectUnauthorized: false
            }
        });

        const mailOptions = {
            from: process.env.SMTP_USER,
            to: email,
            subject: 'Email Verification OTP',
            text: `Your OTP for registration is: ${otp}`
        };

        await transporter.sendMail(mailOptions);
        console.log(`[OTP] Sent to ${email} (via SMTP)`);

        res.json({ message: 'OTP sent to email. Check your inbox.' });
    } catch (err) {
        console.error('SMTP Error:', err);
        res.status(500).json({ error: `Failed to send email: ${err.message}` });
    }
});

// Signup (Verify OTP & Create User)
router.post('/signup', async (req, res) => {
    try {
        const { username, password, otp, role, branch } = req.body; // username is email

        // Verify OTP
        const otpRecord = await Otp.findOne({ email: username, otp }).sort({ createdAt: -1 });
        if (!otpRecord) {
            return res.status(400).json({ message: 'Invalid or expired OTP' });
        }

        // Check if user exists (Double check)
        const existingUser = await User.findOne({ username });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        // Create new user 
        const user = new User({
            username,
            password,
            role: role || 'User', // Default to User/Customer if not specified
            branch: branch || 'Customer' // Default branch for customers
        });

        await user.save();

        // Delete used OTP (optional but good practice, though basic logic might keep it until TTL)
        await Otp.deleteMany({ email: username });

        res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Login
router.post('/login', async (req, res) => {
    try {
        const { username, password } = req.body;
        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ message: 'User not found' });

        // Validate Password (Hash vs Plain)
        // Check if password matches (bcrypt)
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            // FALLBACK: Check if plain text matches (for legacy users)
            if (user.password === password) {
                // Determine if we should upgrade hash here? For now, allowing login.
                // Optionally upgrade to hash: 
                // const salt = await bcrypt.genSalt(10);
                // user.password = await bcrypt.hash(password, salt);
                // await user.save();
            } else {
                return res.status(400).json({ message: 'Invalid credentials' });
            }
        }

        res.json({
            message: 'Login successful',
            user: {
                id: user._id,
                username: user.username,
                role: user.role,
                branch: user.branch
            }
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
