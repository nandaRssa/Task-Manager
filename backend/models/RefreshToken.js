const { v4: uuidv4 } = require('uuid');
const { getDatabase } = require('../config/database');

class RefreshTokenModel {
  static create(userId, token, expiresAt) {
    const db = getDatabase();
    const id = uuidv4();
    db.prepare(
      'INSERT INTO refresh_tokens (id, user_id, token, expires_at) VALUES (?, ?, ?, ?)'
    ).run(id, userId, token, expiresAt);
    return id;
  }

  static findByToken(token) {
    const db = getDatabase();
    return db.prepare(
      'SELECT * FROM refresh_tokens WHERE token = ? AND expires_at > CURRENT_TIMESTAMP'
    ).get(token);
  }

  static deleteByToken(token) {
    const db = getDatabase();
    return db.prepare('DELETE FROM refresh_tokens WHERE token = ?').run(token);
  }

  static deleteAllByUser(userId) {
    const db = getDatabase();
    return db.prepare('DELETE FROM refresh_tokens WHERE user_id = ?').run(userId);
  }

  static cleanExpired() {
    const db = getDatabase();
    return db.prepare('DELETE FROM refresh_tokens WHERE expires_at <= CURRENT_TIMESTAMP').run();
  }
}

module.exports = RefreshTokenModel;
