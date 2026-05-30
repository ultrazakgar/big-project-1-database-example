-- -----------------------------------------------------
-- Schema roulette
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `roulette` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `roulette` ;

-- -----------------------------------------------------
-- drop old data
-- -----------------------------------------------------
SET foreign_key_checks = 0;
drop table if exists `roulette_session`;
drop table if exists `roulette_users`;
drop table if exists `roulette_score`;

-- -----------------------------------------------------
-- Table `roulette`.`roulette_session`
-- -----------------------------------------------------
CREATE TABLE `roulette_session` (
    `id` int NOT NULL AUTO_INCREMENT,
    `sessionid` varchar(32) DEFAULT (uuid_short()),
    `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `user_id` int DEFAULT NULL COMMENT 'Пользователь. Если NULL - неавторизован',
    `userdata` json DEFAULT NULL COMMENT 'Данные пользователя',
    PRIMARY KEY (`id`),
    UNIQUE KEY `sessionid` (`sessionid`),
    KEY `user_id` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `roulette_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Лог доступа к игре';

-- -----------------------------------------------------
-- Table `roulette`.`roulette_users`
-- -----------------------------------------------------
CREATE TABLE `roulette_users` (
    `user_id` int NOT NULL AUTO_INCREMENT,
    `name` varchar(128) DEFAULT NULL COMMENT 'Ник пользователя',
    `data` json DEFAULT NULL COMMENT 'Дополнительные данные, неопределенного формата, вдруг понадобятся',
    `created` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `banned` tinyint(1) DEFAULT '0' COMMENT 'Способ отключить пользователя.',
    PRIMARY KEY (`user_id`),
    KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Зарегистрированные пользователи';

-- -----------------------------------------------------
-- Table `roulette`.`roulette_score`
-- -----------------------------------------------------
CREATE TABLE `roulette_score` (
    `id` int NOT NULL AUTO_INCREMENT,
    `user_id` int DEFAULT NULL COMMENT 'Пользователь',
    `score` int DEFAULT NULL,
    `created` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `user_id` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `roulette_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP PROCEDURE IF EXISTS CreateNewSession;
DELIMITER $$
CREATE PROCEDURE `CreateNewSession`(
    IN p_data JSON,
    OUT p_session_id varchar(32)
)
BEGIN

	SET p_session_id = UUID_SHORT();
    INSERT INTO roulette_session (sessionid,userdata) VALUES (p_session_id,p_data);

END$$
DELIMITER ;

SET foreign_key_checks = 1; -- возврщаем провеку внешних ключей
