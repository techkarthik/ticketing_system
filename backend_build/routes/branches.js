const express = require('express');
const router = express.Router();
const Branch = require('../models/Branch');
const jwt = require('jsonwebtoken');

// Middleware mostly same as user.js, maybe refactor to middleware file later?
// For now duplication is faster.
const auth = (req, res, next) => {
    const token = req.header('x-auth-token');
    if (!token) {
        console.log('Auth Middleware: No token provided');
        return res.status(401).json({ message: 'No token, authorization denied' });
    }
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded.user;
        console.log(`Auth Middleware: Verified user ${req.user.id} role: ${req.user.role}`);
        next();
    } catch (e) {
        console.error('Auth Middleware: Verification failed', e.message);
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

// GET All Branches
router.get('/', auth, async (req, res) => {
    try {
        const branches = await Branch.find().sort({ createdAt: -1 });
        res.json(branches);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// CREATE Branch
router.post('/', adminAuth, async (req, res) => {
    try {
        const { branchname, location, active, branchtype } = req.body;

        let branch = await Branch.findOne({ branchname });
        if (branch) return res.status(400).json({ message: 'Branch already exists' });

        branch = new Branch({ branchname, location, active, branchtype });
        await branch.save();
        res.json(branch);
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
});

// UPDATE Branch
router.put('/:id', adminAuth, async (req, res) => {
    try {
        const branch = await Branch.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );
        res.json(branch);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;
