const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Create User (Admin only)
router.post('/create-user', async (req, res) => {
    try {
        const { username, password, role, branch } = req.body;

        const existingUser = await User.findOne({ username });
        if (existingUser) return res.status(400).json({ message: 'User already exists' });

        const user = new User({
            username,
            password,
            role,
            branch
        });

        await user.save();
        res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
