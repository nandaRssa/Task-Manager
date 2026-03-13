const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../config/database');

class UserModel {
  static findByEmail(email) {
    const db = getDatabase();
    return db.prepare('SELECT * FROM users WHERE email = ?').get(email);
  }

  static findById(id) {
    const db = getDatabase();
    return db.prepare('SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?').get(id);
  }

  static create({ name, email, password }) {
    const db = getDatabase();
    const id = uuidv4();
    const stmt = db.prepare(
      'INSERT INTO users (id, name, email, password) VALUES (?, ?, ?, ?)'
    );
    stmt.run(id, name, email, password);
    return this.findById(id);
  }
}

module.exports = UserModel;
