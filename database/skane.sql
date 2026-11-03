-- Skane University Housing Platform - MySQL schema
CREATE DATABASE skane;
USE skane;
 
CREATE TABLE users (
  user_id  INT IDENTITY(1,1) PRIMARY KEY,
  name     NVARCHAR(100) NOT NULL,
  email    NVARCHAR(150) NOT NULL UNIQUE,
  phone    NVARCHAR(20),
  password NVARCHAR(255) NOT NULL,              -- store hashed
  role     NVARCHAR(10)  NOT NULL CHECK (role IN ('Student','Owner','Admin')),
  status   NVARCHAR(10)  NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Blocked'))
);
 
CREATE TABLE admin (
  ad_id   INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
 
CREATE TABLE student (
  st_id          INT IDENTITY(1,1) PRIMARY KEY,
  user_id        INT NOT NULL UNIQUE,
  faculty        NVARCHAR(100),
  academic_year  TINYINT,
  gender         NVARCHAR(10) NOT NULL CHECK (gender IN ('Male','Female')),
  university     NVARCHAR(150) NOT NULL,
  preferred_area NVARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
 
CREATE TABLE owner (
  ow_id               INT IDENTITY(1,1) PRIMARY KEY,
  user_id             INT NOT NULL UNIQUE,
  national_id         NVARCHAR(20) NOT NULL UNIQUE,
  verification_status NVARCHAR(10) NOT NULL DEFAULT 'Pending'
                      CHECK (verification_status IN ('Pending','Verified','Rejected')),
  verified_by         INT NULL,
  FOREIGN KEY (user_id)     REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (verified_by) REFERENCES admin(ad_id)
);
 
CREATE TABLE house (
  fl_id         INT IDENTITY(1,1) PRIMARY KEY,
  ow_id         INT NOT NULL,
  approved_by   INT NULL,
  title         NVARCHAR(150) NOT NULL,
  description   NVARCHAR(MAX),
  address       NVARCHAR(255),
  city          NVARCHAR(100),
  area          NVARCHAR(100),
  location_link NVARCHAR(500),
  gender        NVARCHAR(10) NOT NULL CHECK (gender IN ('Boys','Girls')),
  type          NVARCHAR(50),
  status        NVARCHAR(20) NOT NULL DEFAULT 'Pending Review'
                CHECK (status IN ('Pending Review','Approved','Rejected')),
  FOREIGN KEY (ow_id)       REFERENCES owner(ow_id),
  FOREIGN KEY (approved_by) REFERENCES admin(ad_id)
);
 
CREATE TABLE house_image (
  img_id  INT IDENTITY(1,1) PRIMARY KEY,
  fl_id   INT NOT NULL,
  img_url NVARCHAR(500) NOT NULL,
  FOREIGN KEY (fl_id) REFERENCES house(fl_id) ON DELETE CASCADE
);
 
CREATE TABLE room (
  ro_id            INT IDENTITY(1,1) PRIMARY KEY,
  fl_id            INT NOT NULL,
  type             NVARCHAR(50),
  capacity         INT NOT NULL CHECK (capacity > 0),
  price            DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  available_spaces INT NOT NULL,
  CONSTRAINT chk_spaces CHECK (available_spaces >= 0 AND available_spaces <= capacity),
  FOREIGN KEY (fl_id) REFERENCES house(fl_id) ON DELETE CASCADE
);
 
CREATE TABLE booking (
  bo_id      INT IDENTITY(1,1) PRIMARY KEY,
  st_id      INT NOT NULL,
  ro_id      INT NOT NULL,
  checked_by INT NULL,
  start_date DATE NOT NULL,
  end_date   DATE NOT NULL,
  status     NVARCHAR(10) NOT NULL DEFAULT 'Pending'
             CHECK (status IN ('Pending','Accepted','Rejected','Cancelled')),
  CONSTRAINT chk_dates CHECK (end_date > start_date),
  FOREIGN KEY (st_id)      REFERENCES student(st_id),
  FOREIGN KEY (ro_id)      REFERENCES room(ro_id),
  FOREIGN KEY (checked_by) REFERENCES admin(ad_id)
);
 
CREATE TABLE payment (
  pay_id     INT IDENTITY(1,1) PRIMARY KEY,
  bo_id      INT NOT NULL UNIQUE,               -- enforces 1:1 with booking
  amount     DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
  pay_method NVARCHAR(30) NOT NULL DEFAULT 'Electronic Wallet'
             CHECK (pay_method IN ('Electronic Wallet')),
  pay_status NVARCHAR(10) NOT NULL DEFAULT 'Pending'
             CHECK (pay_status IN ('Pending','Paid','Failed')),
  pay_at     DATETIME2 NULL,
  FOREIGN KEY (bo_id) REFERENCES booking(bo_id) ON DELETE CASCADE
);
 
CREATE TABLE review (
  rev_id  INT IDENTITY(1,1) PRIMARY KEY,
  st_id   INT NOT NULL,
  ro_id   INT NOT NULL,
  rating  TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment NVARCHAR(MAX),
  FOREIGN KEY (st_id) REFERENCES student(st_id),
  FOREIGN KEY (ro_id) REFERENCES room(ro_id)
);
 
-- Useful indexes for the student filters (area / gender / price)
CREATE INDEX idx_house_filter ON house (status, area, gender);
CREATE INDEX idx_room_price   ON room (price);