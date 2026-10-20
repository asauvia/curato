const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const dotenv = require("dotenv");
const Admin = require("./src/model/Admin.js");

dotenv.config();

const seedAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB");

        const email = process.env.SEED_ADMIN_EMAIL;
        const password = process.env.SEED_ADMIN_PASSWORD;
        if (!email || !password) throw new Error("set SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD to seed the admin");

        const existingAdmin = await Admin.findOne({ email });
        if (existingAdmin) {
            console.log("Admin already exists. Updating password...");
            const hashpass = await bcrypt.hash(password, 10);
            existingAdmin.password = hashpass;
            existingAdmin.name = "Curato Admin";
            await existingAdmin.save();
            console.log("Admin password updated successfully");
        } else {
            const hashpass = await bcrypt.hash(password, 10);
            await Admin.create({
                name: "Curato Admin",
                email: email,
                password: hashpass,
            });
            console.log("Admin created successfully");
        }

        mongoose.connection.close();
        process.exit(0);
    } catch (error) {
        console.error("Error seeding admin:", error.message);
        process.exit(1);
    }
};

seedAdmin();
