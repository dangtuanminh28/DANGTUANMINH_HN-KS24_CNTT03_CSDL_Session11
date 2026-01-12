drop database if exists session11;
create database session11;
use session11;

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  gender ENUM('Nam', 'Nữ') NOT NULL DEFAULT 'Nam',
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  birthdate DATE,
  hometown VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT posts_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT comments_fk_posts FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT comments_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE likes (
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (post_id, user_id),
  CONSTRAINT likes_fk_posts FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT likes_fk_users FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO users (username, full_name, gender, email, password, birthdate, hometown) VALUES
('an', 'Nguyễn Văn An', 'Nam', 'an@gmail.com', '123', '1990-01-01', 'Hà Nội'),
('binh', 'Trần Thị Bình', 'Nữ', 'binh@gmail.com', '123', '1992-02-15', 'TP.HCM'),
('chi', 'Lê Minh Chi', 'Nữ', 'chi@gmail.com', '123', '1991-03-10', 'Đà Nẵng'),
('duy', 'Phạm Quốc Duy', 'Nam', 'duy@gmail.com', '123', '1990-05-20', 'Hải Phòng'),
('ha', 'Vũ Thu Hà', 'Nữ', 'ha@gmail.com', '123', '1994-07-25', 'Hà Nội'),
('hieu', 'Đặng Hữu Hiếu', 'Nam', 'hieu@gmail.com', '123', '1993-11-30', 'TP.HCM');

INSERT INTO posts (user_id, content) VALUES
(1,'Chào mọi người! Hôm nay mình bắt đầu học MySQL.'),
(2,'Ai có tài liệu SQL cơ bản cho người mới không?'),
(3,'Mình đang luyện JOIN, hơi rối nhưng vui.'),
(4,'Thiết kế ERD xong thấy dữ liệu rõ ràng hơn hẳn.'),
(5,'Học chuẩn hoá (normalization) giúp tránh trùng dữ liệu.'),
(6,'Tối ưu truy vấn: nhớ tạo index đúng chỗ.');

INSERT INTO comments (post_id, user_id, content, created_at) VALUES
(4, 2, 'Đà Lạt mùa này mát lắm, đi đi bạn!', '2024-01-27 16:15:00'),
(5, 5, 'Mình đi tuần trước rồi, đẹp cực!', '2024-01-27 17:30:00'),
(6, 6, 'Tag mình vào với, muốn đi quá', '2024-01-27 18:45:00'),
(2, 3, 'Mình cũng chán học online rồi, muốn gặp mặt lắm', '2024-09-08 10:20:00'),
(2, 6, 'Offline mới có động lực học chứ', '2024-09-08 11:40:00'),
(3, 1, 'Công thức này mình lưu lại nấu thử cuối tuần', '2024-04-15 20:00:00');

INSERT INTO likes (post_id, user_id, created_at) VALUES
(1, 1, '2024-01-27 16:20:00'),
(3, 3, '2024-01-27 17:00:00'),
(3, 5, '2024-01-27 17:45:00'),
(4, 2, '2024-01-27 18:30:00'),
(5, 4, '2024-01-27 19:15:00'),
(6, 2, '2024-09-08 10:30:00');

DELIMITER //
CREATE PROCEDURE CalculateUserActivityScore(IN p_user_id INT, OUT activity_score INT, OUT activity_level VARCHAR(50))
BEGIN
    -- Tính tổng điểm trực tiếp bằng cách cộng các câu truy vấn con
    SET activity_score = 
        (SELECT COUNT(post_id) * 10 FROM posts WHERE user_id = p_user_id) +
        (SELECT COUNT(comment_id) * 5 FROM comments WHERE user_id = p_user_id) +
        (SELECT COUNT(l.user_id) * 3 
         FROM likes l 
         JOIN posts p ON l.post_id = p.post_id 
         WHERE p.user_id = p_user_id);
    -- Phân loại mức hoạt động trực tiếp dựa trên biến OUT activity_score
    SET activity_level = CASE 
        WHEN activity_score > 500 THEN 'Rất tích cực'
        WHEN activity_score BETWEEN 200 AND 500 THEN 'Tích cực'
        ELSE 'Bình thường'
    END;
END //
DELIMITER ;

CALL CalculateUserActivityScore(1, @score, @level);
SELECT @score AS 'Tổng điểm', 
		@level AS 'Mức độ hoạt động';
DROP PROCEDURE IF EXISTS CalculateUserActivityScore;