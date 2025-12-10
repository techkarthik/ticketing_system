const User = require('../models/User');

const isAdmin = async (req, res, next) => {
    // In a real app, we would verify JWT here and extract user ID.
    // For this MVP, we will pass 'userId' in headers or body for verification (Simplified)
    // OR, since we haven't implemented full JWT yet, we trust the client to send the user ID.
    // TO DO: Implement JWT Middleware.

    // For now, let's assume the frontend sends 'x-user-id' header.
    const userId = req.headers['x-user-id'];
    if (!userId) {
        // If testing with Postman without header, maybe skip? No, security first.
        return res.status(401).json({ message: 'Unauthorized' });
    }

    try {
        const user = await User.findById(userId);
        if (user && user.role === 'Admin') {
            next();
        } else {
            res.status(403).json({ message: 'Access denied. Admins only.' });
        }
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = isAdmin;
