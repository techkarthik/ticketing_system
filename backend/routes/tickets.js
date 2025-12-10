const express = require('express');
const router = express.Router();
const Ticket = require('../models/Ticket');

// Create Ticket
router.post('/', async (req, res) => {
    try {
        const { title, description, category, priority, branch, createdBy, assignedTo } = req.body;

        const ticket = new Ticket({
            title,
            description,
            category,
            priority,
            branch,
            createdBy,
            assignedTo
        });

        await ticket.save();
        res.status(201).json(ticket);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get Ticket Stats
router.get('/stats', async (req, res) => {
    try {
        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);

        const pendingCount = await Ticket.countDocuments({ status: { $ne: 'Closed' } });
        const createdToday = await Ticket.countDocuments({ createdAt: { $gte: todayStart } });
        const closedToday = await Ticket.countDocuments({
            status: 'Closed',
            updatedAt: { $gte: todayStart }
        });

        res.json({
            pending: pendingCount,
            createdToday: createdToday,
            closedToday: closedToday
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Get Tickets (with filters)
router.get('/', async (req, res) => {
    try {
        const { role, userId, branch } = req.query;
        console.log('GET /tickets Query:', req.query); // Debug log
        let filter = {};

        // Role-based filtering logic
        // Role-based filtering logic
        if (role === 'Staff') {
            // Staff sees tickets they created OR assigned to them
            filter.$or = [{ createdBy: userId }, { assignedTo: userId }];
        } else if (role === 'User') {
            // Customers/Users only see tickets they created
            filter.createdBy = userId;
        } else if (role === 'Supervisor') {
            // Supervisor sees:
            // 1. Tickets in their branch
            // 2. Tickets they created (even if for other branches)
            // 3. Tickets assigned to them
            let conditions = [];

            // Base visibility for Supervisor (Branch context)
            if (branch) conditions.push({ branch: branch });
            if (userId) {
                conditions.push({ createdBy: userId });
                conditions.push({ assignedTo: userId });
            }

            if (conditions.length > 0) {
                filter.$or = conditions;
            }
        }
        // Admin sees all (empty filter)

        // Apply additional filters if present (intersection)
        // Note: If 'role' logic already set filter.$or, we need to be careful not to break it.
        // But Mongoose doesn't easily support "$or AND other_fields" at top level if $or is top level?
        // Wait, { $or: [...], status: 'Open' } works fine in MongoDB. It implies AND.

        const { status, location } = req.query; // location = branch filter from Report screen
        // Note: 'branch' query param was used above for User's Branch context. 
        // We need to distinguish between "User's context branch" and "Filter branch".
        // In the dashboard call: `fetchTickets(role: user.role, userId: user.id, branch: user.branch)`
        // So 'branch' in query IS the user's branch.
        // If we want to filter by a DIFFERENT branch (for Admin), we might need a different param or check logic.
        // IF Admin: 'branch' param acts as filter.
        // IF Supervisor: 'branch' param acts as layout? No, Supervisor is usually restricted to their branch.
        // Let's assume for Report, we pass 'filterBranch' to distinguish? 
        // Or reuse 'branch'. If Admin, 'branch' is the filter.

        if (status) {
            filter.status = status;
        }

        // Use 'filterBranch' for explicit reporting filter to avoid confusion with user context 'branch'
        // OR just handle 'branch' smartly.
        // existing code: `const { role, userId, branch } = req.query;`
        // If role is Admin, 'branch' is currently ignored in the logical block above.
        // So for Admin, we can just say: if (branch) filter.branch = branch;

        if (role === 'Admin' && branch) {
            filter.branch = branch;
        }

        // For Supervisor, they are restricted to 'branch' (their branch). 
        // If they want to filter, it must be their branch anyway.
        // If multiple branches exist for a supervisor? No, 1 branch model.

        // Let's keep it simple.
        if (status) filter.status = status;

        const tickets = await Ticket.find(filter)
            .populate('createdBy', 'username')
            .populate('assignedTo', 'username');
        res.json(tickets);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Update Ticket (Status/Reassign)
router.put('/:id', async (req, res) => {
    try {
        const { status, assignedTo } = req.body;
        const ticket = await Ticket.findByIdAndUpdate(
            req.params.id,
            { status, assignedTo },
            { new: true }
        ).populate('createdBy', 'username').populate('assignedTo', 'username');
        res.json(ticket);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
