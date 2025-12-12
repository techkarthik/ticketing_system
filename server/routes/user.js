const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

// Middleware to verify token and admin status
const auth = (req, res, next) => {
    const token = req.header('x-auth-token');
    if (!token) return res.status(401).json({ message: 'No token, authorization denied' });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded.user;
        next();
    } catch (e) {
        res.status(400).json({ message: 'Token is not valid' });
    }
};

const adminAuth = (req, res, next) => {
    auth(req, res, () => {
        if (req.user.role === 'ADMIN' || req.user.role === 'SUPERADMIN') {
            next();
        } else {
            res.status(403).json("You are not allowed to do that!");
        }
    });
};

// Get Current User (Me)
router.get('/me', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password');
        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Get All Users (Admin/SuperAdmin only)
router.get('/', adminAuth, async (req, res) => {
    try {
        const users = await User.find().select('-password').sort({ createdAt: -1 });
        res.json(users);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Update User (Admin/SuperAdmin only)
router.put('/:id', adminAuth, async (req, res) => {
    try {
        const { personName, mobilenumber, role, isadmin, branch, department } = req.body;

        let userFields = {};
        if (personName) userFields.personName = personName;
        if (mobilenumber) userFields.mobilenumber = mobilenumber;
        if (role) userFields.role = role;
        if (isadmin !== undefined) userFields.isadmin = isadmin;
        if (branch) userFields.branch = branch;
        if (department) userFields.department = department;
        if (role) userFields.role = role;
        if (isadmin !== undefined) userFields.isadmin = isadmin;

        // Optionally update password if provided? (Not in requirements yet, keep simple)

        let user = await User.findById(req.params.id);
        if (!user) return res.status(404).json({ message: 'User not found' });

        user = await User.findByIdAndUpdate(
            req.params.id,
            { $set: userFields },
            { new: true }
        ).select('-password');

        res.json(user);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});



// Change Password
router.put('/change-password', auth, async (req, res) => {
    try {
        const { oldPassword, newPassword } = req.body;
        console.log(`Change Password Request for user ${req.user.id}`);
        const user = await User.findById(req.user.id);

        if (!user) {
            console.log('User not found during password change');
            return res.status(404).json({ message: 'User not found' });
        }

        // Debug logging (remove in prod if sensitive, but useful now)
        // console.log('Old Password Hash:', user.password); 
        // console.log('Provided Old Password:', oldPassword);

        const isMatch = await bcrypt.compare(oldPassword, user.password);
        if (!isMatch) {
            console.log('Password mismatch');
            return res.status(400).json({ message: 'Incorrect old password' });
        }



        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(newPassword, salt);
        await user.save();

        res.json({ message: 'Password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// Add User (Admin/SuperAdmin only)
router.post('/add', adminAuth, async (req, res) => {
    try {
        const { username, password, mobilenumber, role, isadmin, personName, branch, department } = req.body;

        let user = await User.findOne({ username });
        if (user) {
            return res.status(400).json({ message: 'User already exists' });
        }

        user = new User({
            username,
            password,
            mobilenumber,
            role,
            isadmin,
            personName: personName || 'Unknown',
            branch,
            department
        });

        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(password, salt);

        console.log(`Backend: Creating user ${username} linked to Branch: ${branch}, Dept: ${department}`);

        await user.save();
        res.json({ message: 'User created successfully' });
    } catch (err) {
        console.error('Backend Error (Add User):', err.message);
        res.status(500).send('Server Error: ' + err.message);
    }
});
module.exports = router;
