const mongoose = require('mongoose');
const User = require('./models/User');

// Helper for fetch
async function post(url, data) {
    const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
    return res.json();
}

async function get(url, params) {
    const query = new URLSearchParams(params).toString();
    const res = await fetch(`${url}?${query}`);
    return res.json();
}

// Connect to DB
mongoose.connect('mongodb+srv://techkarthikmahalingam:PFXpa8U4GupQNRe0@cluster0.wkrky.mongodb.net/ticketing_system')
    .then(async () => {
        console.log('Connected to DB');

        try {
            // 1. Create/Get Users
            let staff1 = await User.findOne({ username: 'staff1' });
            if (!staff1) {
                staff1 = new User({ username: 'staff1', password: '123', role: 'Staff', branch: 'Chennai' });
                await staff1.save();
                console.log('Created staff1');
            } else {
                console.log('Found staff1');
            }

            let admin = await User.findOne({ username: 'admin' });
            if (!admin) {
                console.log('Admin not found, strictly expecting admin from seed');
                return;
            }

            const staffId = staff1._id.toString();
            const adminId = admin._id.toString();

            console.log(`Staff1 ID: ${staffId}`);
            console.log(`Admin ID: ${adminId}`);

            const API_URL = 'http://localhost:5000/api';

            // 2. Create Ticket assigned to Staff1 (as Admin)
            console.log('Creating ticket...');
            const createRes = await post(`${API_URL}/tickets`, {
                title: 'Fetch Test Ticket',
                description: 'Testing if staff1 can see this',
                category: 'Software',
                priority: 'High',
                branch: 'Chennai',
                createdBy: adminId,
                assignedTo: staffId
            });

            if (createRes.error) {
                console.error('Error creating ticket:', createRes.error);
                return;
            }
            console.log('Ticket Created:', createRes._id);

            // 3. Fetch Tickets as Staff1
            console.log('Fetching tickets as Staff1...');
            const fetchRes = await get(`${API_URL}/tickets`, {
                role: 'Staff',
                userId: staffId,
                branch: 'Chennai'
            });

            if (fetchRes.error) {
                console.error('Error fetching tickets:', fetchRes.error);
                return;
            }

            console.log(`Fetched ${fetchRes.length} tickets`);
            const found = fetchRes.find(t => t._id === createRes._id);

            if (found) {
                console.log('SUCCESS: Assigned ticket is visible!');
                // Verify assignedTo field in response
                if (found.assignedTo && found.assignedTo._id === staffId) {
                    console.log('SUCCESS: assignedTo field is correctly populated.');
                } else {
                    console.log('WARNING: assignedTo field might be missing or incorrect:', found.assignedTo);
                }
            } else {
                console.log('FAILURE: Assigned ticket NOT found in list.');
                console.log('List IDs:', fetchRes.map(t => t._id));
            }

        } catch (e) {
            console.error('Error:', e);
        } finally {
            mongoose.disconnect();
        }
    });
