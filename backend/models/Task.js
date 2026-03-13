const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../config/database');

class TaskModel {
  static findAllByUser(userId) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM tasks WHERE user_id = ? ORDER BY created_at DESC'
    ).all(userId);
  }

  static findByIdAndUser(id, userId) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM tasks WHERE id = ? AND user_id = ?'
    ).get(id, userId);
  }

  static create({ title, description, status = 'pending', userId }) {
    const db = getDatabase();
    const id = uuidv4();
    db.prepare(
      'INSERT INTO tasks (id, title, description, status, user_id) VALUES (?, ?, ?, ?, ?)'
    ).run(id, title, description || null, status, userId);
    return this.findByIdAndUser(id, userId);
  }

  static update(id, userId, { title, description, status }) {
    const db = getDatabase();
    const fields = [];
    const values = [];

    if (title !== undefined) { fields.push('title = ?'); values.push(title); }
    if (description !== undefined) { fields.push('description = ?'); values.push(description); }
    if (status !== undefined) { fields.push('status = ?'); values.push(status); }

    if (fields.length === 0) return this.findByIdAndUser(id, userId);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id, userId);

    db.prepare(
      `UPDATE tasks SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`
    ).run(...values);

    return this.findByIdAndUser(id, userId);
  }

  static delete(id, userId) {
    const db = getDatabase();
    const result = db.prepare(
      'DELETE FROM tasks WHERE id = ? AND user_id = ?'
    ).run(id, userId);
    return result.changes > 0;
  }
}

module.exports = TaskModel;
