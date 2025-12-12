const express = require('express');
const router = express.Router();
const Department = require('../models/Department');
const jwt = require('jsonwebtoken');

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

// GET All Departments
router.get('/', auth, async (req, res) => {
    try {
        const departments = await Department.find().sort({ createdAt: -1 });
        res.json(departments);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// CREATE Department
router.post('/', adminAuth, async (req, res) => {
    try {
        const { name } = req.body;
        let department = await Department.findOne({ name });
        if (department) return res.status(400).json({ message: 'Department already exists' });

        department = new Department({ name });
        await department.save();
        res.json(department);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

// UPDATE Department
router.put('/:id', adminAuth, async (req, res) => {
    try {
        const department = await Department.findByIdAndUpdate(
            req.params.id,
            { $set: req.body },
            { new: true }
        );
        res.json(department);
    } catch (err) {
        res.status(500).send('Server Error');
    }
});

module.exports = router;
