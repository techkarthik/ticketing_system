const express = require('express');
const router = express.Router();
const Branch = require('../models/Branch');
const Category = require('../models/Category');
const User = require('../models/User');

// Get all branches
router.get('/branches', async (req, res) => {
    try {
        const branches = await Branch.find();
        res.json(branches);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Create Branch
router.post('/branches', async (req, res) => {
    try {
        const { name } = req.body;
        const branch = new Branch({ name });
        await branch.save();
        res.status(201).json(branch);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update Branch
router.put('/branches/:id', async (req, res) => {
    try {
        const { name } = req.body;
        const branch = await Branch.findByIdAndUpdate(
            req.params.id,
            { name },
            { new: true }
        );
        res.json(branch);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all categories
router.get('/categories', async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get all users (for assignment)
router.get('/users', async (req, res) => {
    try {
        const users = await User.find({}, 'username branch role'); // Return only necessary fields
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
