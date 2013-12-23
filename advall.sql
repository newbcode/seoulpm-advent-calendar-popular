CREATE TABLE `advall` (
  `id`          INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `author`      VARCHAR(20)      NOT NULL DEFAULT '',
  `title`       VARCHAR(70)      NOT NULL,
  `url`         TEXT             NOT NULL,
  `likesum`     INT(2)           NOT NULL,
  `year`        INT(2)           NOT NULL,
  `wdate`       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
