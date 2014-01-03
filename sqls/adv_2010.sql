CREATE TABLE `adv_2010` (
  `id`          INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `author`      VARCHAR(512)      NOT NULL DEFAULT '',
  `title`       VARCHAR(512)      NOT NULL,
  `url`         TEXT             NOT NULL,
  `abst`        TEXT             NOT NULL,
  `likesum`     INT(2)           NOT NULL,
  `year`        INT(2)           NOT NULL,
  `wdate`       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
 
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
