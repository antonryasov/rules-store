-- RULES. ONLY, NEW EMPTY D1. Never run on BIORYX or a populated database.

-- FILE: 0001_catalog.sql
-- RULES.: отдельная база D1, не использовать базу старого магазина.
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  sku TEXT NOT NULL DEFAULT '',
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('candle','diffuser','perfume','sets')),
  description TEXT NOT NULL DEFAULT '',
  price INTEGER NOT NULL CHECK (price >= 0),
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  image TEXT NOT NULL DEFAULT '',
  active INTEGER NOT NULL DEFAULT 0 CHECK (active IN (0, 1)),
  sort_order INTEGER NOT NULL DEFAULT 100,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS products_listing ON products(active, sort_order, name);


-- FILE: 0002_orders.sql
CREATE TABLE IF NOT EXISTS orders (
 id TEXT PRIMARY KEY, created_at TEXT NOT NULL DEFAULT (datetime('now')),
 customer_name TEXT NOT NULL, phone TEXT NOT NULL, city TEXT NOT NULL, address TEXT NOT NULL DEFAULT '',
 delivery TEXT NOT NULL CHECK(delivery IN ('pickup','courier','cdek')),
 payment TEXT NOT NULL CHECK(payment IN ('cash','sbp','card')),
 comment TEXT NOT NULL DEFAULT '', total INTEGER NOT NULL DEFAULT 0,
 status TEXT NOT NULL DEFAULT 'new', payment_status TEXT NOT NULL DEFAULT 'unpaid', consent INTEGER NOT NULL CHECK(consent=1)
);
CREATE TABLE IF NOT EXISTS order_items (
 id INTEGER PRIMARY KEY AUTOINCREMENT, order_id TEXT NOT NULL REFERENCES orders(id), product_id TEXT NOT NULL,
 name TEXT NOT NULL, price INTEGER NOT NULL, qty INTEGER NOT NULL CHECK(qty BETWEEN 1 AND 20)
);
CREATE TABLE IF NOT EXISTS outbox (
 id INTEGER PRIMARY KEY AUTOINCREMENT, order_id TEXT NOT NULL UNIQUE, state TEXT NOT NULL DEFAULT 'pending',
 attempts INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL DEFAULT (datetime('now')), last_error TEXT NOT NULL DEFAULT ''
);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_outbox_pending ON outbox(state,id);
CREATE TRIGGER IF NOT EXISTS reserve_stock BEFORE INSERT ON order_items BEGIN
 SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM products WHERE id=NEW.product_id AND active=1 AND stock>=NEW.qty AND price=NEW.price AND name=NEW.name)
 THEN RAISE(ABORT, 'product_unavailable') END;
 UPDATE products SET stock=stock-NEW.qty WHERE id=NEW.product_id;
END;


-- FILE: 0003_demo_products.sql
-- RULES. / стартовый ассортимент; рабочие цены и категории требуют сверки владельцем.
-- Остатки по 50. Использовать только при первоначальном создании отдельной базы RULES.
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-01','RULES-01','ОПОРА / ANCHOR / СВЕЧА','candle','Когда вокруг шумно, важно знать, на чём стоишь. ОПОРА — древесная глубина и прохладный воздух для пространства с характером.',2190,50,'assets/visual-characters.png',1,1);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-02','RULES-02','ВОЛЯ / WILL / ДИФФУЗОР','diffuser','ВОЛЯ — прохлада трав и сухой воздух высоты. Для тех моментов, когда направление выбираешь сам.',2490,50,'assets/visual-characters.png',1,2);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-03','RULES-03','ХАРАКТЕР / CHARACTER / ПАРФЮМ','perfume','ХАРАКТЕР не нуждается в громких словах. Кожа, чёрный чай и дерево оставляют впечатление надолго.',3490,50,'assets/visual-characters.png',1,3);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-04','RULES-04','СВОБОДА / FREE / ДИФФУЗОР','diffuser','СВОБОДА — когда перед тобой больше воздуха, чем границ. Прохладная зелень и светлая древесина.',2490,50,'assets/visual-characters.png',1,4);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-05','RULES-05','СТЕРЖЕНЬ / CORE / СВЕЧА','candle','СТЕРЖЕНЬ — глубина без показной тяжести. Ореховая сухость, древесина и тёплая амбра.',2190,50,'assets/visual-characters.png',1,5);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-06','RULES-06','НОЧИ ГРОЗНОГО / GROZNY NIGHTS / ПАРФЮМ','perfume','Огни города, тёмная кожа и терпкий гранат. НОЧИ ГРОЗНОГО — вечер, у которого есть собственный ритм.',3490,50,'assets/visual-atlas.png',1,6);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-07','RULES-07','КЕЗЕНОЙ-АМ / ПЕРВЫЙ СВЕТ / ДИФФУЗОР','diffuser','Первый свет на воде. Прохладный воздух, камень и тишина, в которой слышно себя.',2490,50,'assets/visual-atlas.png',1,7);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-08','RULES-08','СУЛАК / ВЫСОТА / ДИФФУЗОР','diffuser','Высота меняет масштаб. Сухой ветер, камень и травы — пространство, которое не нужно объяснять.',2490,50,'assets/visual-atlas.png',1,8);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-09','RULES-09','ДЕРБЕНТ / СТЕНЫ И САДЫ / СВЕЧА','candle','Тёплый камень хранит время. Терпкий гранат и зелень инжира добавляют ему жизнь.',2190,50,'assets/visual-atlas.png',1,9);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-10','RULES-10','ХОЙ / КАМЕНЬ И ОБЛАКА / СВЕЧА','candle','Камень, воздух, высота. ХОЙ — спокойная глубина пространства, в котором время идёт иначе.',2190,50,'assets/visual-atlas.png',1,10);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-11','RULES-11','КОЖА / ГРАНАТ / ПАРФЮМ','perfume','Терпкость встречает глубину. Гранат и кожа — контраст, который невозможно не заметить.',3490,50,'assets/visual-contrasts.png',1,11);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-12','RULES-12','ИНЖИР / ДЫМ / СВЕЧА','candle','Зелёный инжир и тонкая дымка. Мягкость, у которой есть острый край.',2190,50,'assets/visual-contrasts.png',1,12);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-13','RULES-13','ЧАБРЕЦ / СЕРЕБРО / ДИФФУЗОР','diffuser','Дикая трава и холодный свет. ЧАБРЕЦ / СЕРЕБРО — свежесть с характером.',2490,50,'assets/visual-contrasts.png',1,13);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-14','RULES-14','ОРЕХ / КАМЕНЬ / СВЕЧА','candle','Тёплая сухость ореха. Холод камня. Сдержанный контраст для пространства, в котором всё на своём месте.',2190,50,'assets/visual-contrasts.png',1,14);
INSERT INTO products(id,sku,name,category,description,price,stock,image,active,sort_order) VALUES('rules-15','RULES-15','ОБЛЕПИХА / КЕДР / ДИФФУЗОР','diffuser','Яркая терпкость на тёмном дереве. Солнце и глубина в одном контрасте.',2490,50,'assets/visual-contrasts.png',1,15);


-- FILE: 0004_cancel_orders.sql
-- RULES.: запускать только на отдельной базе RULES., после бэкапа.
-- Запрещаем возврат к активному состоянию: иначе повторная отмена удвоит остаток.
CREATE TRIGGER IF NOT EXISTS bioryx_cancel_guard
BEFORE UPDATE OF status ON orders
WHEN (OLD.status = 'cancelled' AND NEW.status != 'cancelled')
  OR (NEW.status = 'cancelled' AND OLD.status != 'cancelled'
      AND (OLD.status NOT IN ('new','confirmed','packing') OR OLD.payment_status != 'unpaid'))
BEGIN
  SELECT RAISE(ABORT, 'invalid_cancellation_or_refund_required');
END;

-- Возврат только один раз, в рамках той же транзакции что смена статуса.
CREATE TRIGGER IF NOT EXISTS bioryx_cancel_restock
AFTER UPDATE OF status ON orders
WHEN OLD.status != 'cancelled' AND NEW.status = 'cancelled'
BEGIN
  UPDATE products SET stock = stock + COALESCE((
    SELECT SUM(qty) FROM order_items
    WHERE order_id = NEW.id AND product_id = products.id
  ), 0)
  WHERE id IN (SELECT product_id FROM order_items WHERE order_id = NEW.id);
END;


-- FILE: 0005_accounts_foundation.sql
-- Основа RULES. Club. Отдельные таблицы с префиксом bx_. Не активирует ни вход, ни баллы.
-- Запускать только в отдельной тестовой RULES. D1 после резервного копирования.
CREATE TABLE IF NOT EXISTS bx_customers (
  id TEXT PRIMARY KEY,
  telegram_id TEXT NOT NULL UNIQUE,
  telegram_username TEXT NOT NULL DEFAULT '',
  display_name TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_sessions (
  token_hash TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES bx_customers(id),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL,
  revoked_at TEXT
);
CREATE INDEX IF NOT EXISTS bx_sessions_customer ON bx_sessions(customer_id);
CREATE TABLE IF NOT EXISTS bx_login_challenges (
  code_hash TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES bx_customers(id),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  expires_at TEXT NOT NULL,
  consumed_at TEXT,
  attempts INTEGER NOT NULL DEFAULT 0 CHECK (attempts >= 0)
);
CREATE TABLE IF NOT EXISTS bx_order_owners (
  order_id TEXT PRIMARY KEY REFERENCES orders(id),
  customer_id TEXT NOT NULL REFERENCES bx_customers(id),
  linked_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_owner_orders ON bx_order_owners(customer_id, linked_at DESC);
CREATE TABLE IF NOT EXISTS bx_loyalty_ledger (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES bx_customers(id),
  order_id TEXT REFERENCES orders(id),
  kind TEXT NOT NULL CHECK(kind IN ('welcome','earn','redeem','restore','reversal','adjustment')),
  points INTEGER NOT NULL CHECK(points != 0),
  operation_key TEXT NOT NULL UNIQUE,
  note TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_ledger_customer ON bx_loyalty_ledger(customer_id, created_at DESC);
CREATE TABLE IF NOT EXISTS bx_customer_messages (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL REFERENCES orders(id),
  customer_id TEXT NOT NULL REFERENCES bx_customers(id),
  direction TEXT NOT NULL CHECK(direction IN ('customer','seller')),
  body TEXT NOT NULL,
  telegram_update_id TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_messages_order ON bx_customer_messages(order_id,created_at);
CREATE TABLE IF NOT EXISTS bx_news_consent (
  customer_id TEXT PRIMARY KEY REFERENCES bx_customers(id),
  subscribed INTEGER NOT NULL DEFAULT 0 CHECK(subscribed IN (0,1)),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_admin_audit (
  id TEXT PRIMARY KEY,
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  order_id TEXT REFERENCES orders(id),
  details TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_audit_order ON bx_admin_audit(order_id,created_at);


-- FILE: 0006_admin.sql
-- Только для RULES. D1. Повторный запуск не удаляет данные.
CREATE TABLE IF NOT EXISTS bx_admin_login_attempts (
 ip_hash TEXT PRIMARY KEY,
 count INTEGER NOT NULL DEFAULT 0,
 window_start INTEGER NOT NULL
);
CREATE TABLE IF NOT EXISTS bx_order_audit (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 order_id TEXT NOT NULL REFERENCES orders(id),
 action TEXT NOT NULL,
 old_value TEXT NOT NULL DEFAULT '',
 new_value TEXT NOT NULL DEFAULT '',
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_order_audit_order ON bx_order_audit(order_id, created_at DESC);
CREATE TRIGGER IF NOT EXISTS bx_admin_status_audit AFTER UPDATE OF status ON orders
WHEN OLD.status != NEW.status BEGIN
 INSERT INTO bx_order_audit(order_id,action,old_value,new_value) VALUES(NEW.id,'status',OLD.status,NEW.status);
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_payment_audit AFTER UPDATE OF payment_status ON orders
WHEN OLD.payment_status != NEW.payment_status BEGIN
 INSERT INTO bx_order_audit(order_id,action,old_value,new_value) VALUES(NEW.id,'payment',OLD.payment_status,NEW.payment_status);
END;


-- FILE: 0007_bot.sql
CREATE TABLE IF NOT EXISTS bx_bot_context (
 customer_id TEXT PRIMARY KEY REFERENCES bx_customers(id),
 order_id TEXT NOT NULL REFERENCES orders(id),
 updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);


-- FILE: 0008_loyalty_promos.sql
-- RULES.: выполнить после 0004–0007. Не меняет и не удаляет старые заказы.
-- Сначала создайте и проверьте резервную копию D1.
CREATE TABLE IF NOT EXISTS bx_promos (
 code TEXT PRIMARY KEY,
 title TEXT NOT NULL,
 percent INTEGER NOT NULL CHECK(percent BETWEEN 1 AND 100),
 active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_order_finance (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 customer_id TEXT REFERENCES bx_customers(id),
 gross INTEGER NOT NULL CHECK(gross >= 0),
 promo_code TEXT NOT NULL DEFAULT '',
 promo_percent INTEGER NOT NULL DEFAULT 0 CHECK(promo_percent BETWEEN 0 AND 100),
 discount INTEGER NOT NULL DEFAULT 0 CHECK(discount >= 0),
 points_used INTEGER NOT NULL DEFAULT 0 CHECK(points_used >= 0),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TRIGGER IF NOT EXISTS bx_welcome AFTER INSERT ON bx_customers BEGIN
 INSERT OR IGNORE INTO bx_loyalty_ledger(id,customer_id,kind,points,operation_key,note)
 VALUES('welcome:'||NEW.id,NEW.id,'welcome',500,'welcome:'||NEW.id,'Приветственные баллы');
END;
CREATE TRIGGER IF NOT EXISTS bx_finance_guard BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM orders WHERE id=NEW.order_id AND total=NEW.gross AND status='new')
 THEN RAISE(ABORT,'bad_gross') END;
 SELECT CASE WHEN NEW.promo_code='' AND (NEW.promo_percent!=0 OR NEW.discount!=0)
 THEN RAISE(ABORT,'bad_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NOT EXISTS(SELECT 1 FROM bx_promos WHERE code=NEW.promo_code AND active=1 AND percent=NEW.promo_percent)
 THEN RAISE(ABORT,'invalid_promo') END;
 SELECT CASE WHEN NEW.discount != CAST(NEW.gross*NEW.promo_percent/100 AS INTEGER) OR NEW.points_used>NEW.gross-NEW.discount
 THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>0 AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id))
 THEN RAISE(ABORT,'customer_required') END;
 SELECT CASE WHEN NEW.points_used>0 AND NEW.points_used > COALESCE((SELECT SUM(points) FROM bx_loyalty_ledger WHERE customer_id=NEW.customer_id),0)
 THEN RAISE(ABORT,'insufficient_points') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_finance_apply AFTER INSERT ON bx_order_finance BEGIN
 UPDATE orders SET total=NEW.gross-NEW.discount-NEW.points_used WHERE id=NEW.order_id;
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT 'redeem:'||NEW.order_id,NEW.customer_id,NEW.order_id,'redeem',-NEW.points_used,'redeem:'||NEW.order_id,'Оплата баллами'
 WHERE NEW.points_used>0;
END;
CREATE TRIGGER IF NOT EXISTS bx_delivery_guard BEFORE UPDATE OF status ON orders
WHEN NEW.status='delivered' AND OLD.status!='delivered' BEGIN
 SELECT CASE WHEN NEW.payment_status!='paid' THEN RAISE(ABORT,'confirm_payment_first') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_delivered_immutable BEFORE UPDATE OF status ON orders
WHEN OLD.status='delivered' AND NEW.status!='delivered' BEGIN
 SELECT RAISE(ABORT,'delivered_order_requires_refund_workflow');
END;
CREATE TRIGGER IF NOT EXISTS bx_delivery_cashback AFTER UPDATE OF status ON orders
WHEN NEW.status='delivered' AND OLD.status!='delivered' BEGIN
 INSERT OR IGNORE INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT 'earn:'||NEW.id, f.customer_id,NEW.id,'earn',
 CAST(NEW.total * (CASE
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=80000 THEN 50
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=40000 THEN 25
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=15000 THEN 10 ELSE 5 END)/100 AS INTEGER),
 'earn:'||NEW.id,'Кэшбэк за доставленный заказ, без доставки'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND NEW.total>=1
 AND CAST(NEW.total*(CASE
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=80000 THEN 50
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=40000 THEN 25
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=15000 THEN 10 ELSE 5 END)/100 AS INTEGER)>0;
END;
CREATE TRIGGER IF NOT EXISTS bx_cancel_points AFTER UPDATE OF status ON orders
WHEN OLD.status!='cancelled' AND NEW.status='cancelled' BEGIN
 INSERT OR IGNORE INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT 'restore:'||NEW.id,customer_id,NEW.id,'restore',points_used,'restore:'||NEW.id,'Возврат баллов после отмены'
 FROM bx_order_finance WHERE order_id=NEW.id AND customer_id IS NOT NULL AND points_used>0;
END;
INSERT OR IGNORE INTO bx_loyalty_ledger(id,customer_id,kind,points,operation_key,note)
SELECT 'welcome:'||id,id,'welcome',500,'welcome:'||id,'Приветственные баллы' FROM bx_customers;


-- FILE: 0009_news.sql
CREATE TABLE IF NOT EXISTS bx_news_jobs (
 id TEXT PRIMARY KEY,
 body TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_news_queue (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 job_id TEXT NOT NULL REFERENCES bx_news_jobs(id),
 customer_id TEXT NOT NULL REFERENCES bx_customers(id),
 state TEXT NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','sending','sent','failed','skipped')),
 attempts INTEGER NOT NULL DEFAULT 0,
 updated_at TEXT NOT NULL DEFAULT (datetime('now')),
 UNIQUE(job_id,customer_id)
);
CREATE INDEX IF NOT EXISTS bx_news_queue_state ON bx_news_queue(state,id);


-- FILE: 0010_admin_controls_notifications.sql
-- Только текущая база RULES. с миграциями 0004–0009. Сделайте резервную копию.
CREATE TABLE IF NOT EXISTS bx_customer_levels (
 customer_id TEXT PRIMARY KEY REFERENCES bx_customers(id),
 level TEXT NOT NULL CHECK(level IN ('start','progress','power','peak')),
 updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_level_audit (
 id INTEGER PRIMARY KEY AUTOINCREMENT, customer_id TEXT NOT NULL REFERENCES bx_customers(id),
 old_level TEXT NOT NULL DEFAULT 'auto', new_level TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_notification_flags (
 entity_key TEXT PRIMARY KEY, enabled INTEGER NOT NULL CHECK(enabled IN (0,1))
);
CREATE TABLE IF NOT EXISTS bx_notifications (
 id TEXT PRIMARY KEY, customer_id TEXT NOT NULL REFERENCES bx_customers(id),
 body TEXT NOT NULL, state TEXT NOT NULL DEFAULT 'pending' CHECK(state IN ('pending','sending','sent','failed')),
 attempts INTEGER NOT NULL DEFAULT 0, last_error TEXT NOT NULL DEFAULT '',
 created_at TEXT NOT NULL DEFAULT (datetime('now')), updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_notifications_pending ON bx_notifications(state,created_at);
CREATE TRIGGER IF NOT EXISTS bx_notify_ledger AFTER INSERT ON bx_loyalty_ledger
WHEN NEW.kind IN ('welcome','earn','redeem','restore')
 AND COALESCE((SELECT enabled FROM bx_notification_flags WHERE entity_key='order:'||NEW.order_id),1)=1
BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 VALUES('ledger:'||NEW.id,NEW.customer_id,
  CASE NEW.kind
   WHEN 'welcome' THEN '✦ RULES. CLUB' || char(10) || char(10) || 'Добро пожаловать! Вам начислено ' || NEW.points || ' приветственных баллов.' || char(10) || '1 балл = 1 ₽. Ваш путь начинается здесь.'
   WHEN 'earn' THEN '✦ RULES. CLUB' || char(10) || char(10) || 'За доставленный заказ начислено +' || NEW.points || ' баллов.' || char(10) || 'Спасибо, что выбираете RULES.!'
   WHEN 'redeem' THEN '✦ RULES. CLUB' || char(10) || char(10) || 'Для оплаты заказа списано ' || (-NEW.points) || ' баллов.'
   ELSE '✦ RULES. CLUB' || char(10) || char(10) || 'После отмены заказа возвращено +' || NEW.points || ' баллов.' END);
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_payment_method_audit AFTER UPDATE OF payment ON orders
WHEN OLD.payment != NEW.payment BEGIN
 INSERT INTO bx_order_audit(order_id,action,old_value,new_value) VALUES(NEW.id,'payment_method',OLD.payment,NEW.payment);
END;
-- Переопределение уровня влияет на будущий кэшбэк. Историю операций не пересчитываем.
DROP TRIGGER IF EXISTS bx_delivery_cashback;
CREATE TRIGGER IF NOT EXISTS bx_delivery_cashback AFTER UPDATE OF status ON orders
WHEN NEW.status='delivered' AND OLD.status!='delivered' BEGIN
 INSERT OR IGNORE INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT 'earn:'||NEW.id, f.customer_id,NEW.id,'earn',
 CAST(NEW.total * (COALESCE((SELECT CASE level WHEN 'start' THEN 5 WHEN 'progress' THEN 10 WHEN 'power' THEN 25 WHEN 'peak' THEN 50 END FROM bx_customer_levels WHERE customer_id=f.customer_id), CASE
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=80000 THEN 50
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=40000 THEN 25
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=15000 THEN 10 ELSE 5 END))/100 AS INTEGER),
 'earn:'||NEW.id,'Кэшбэк за доставленный заказ, без доставки'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND NEW.total>=1
 AND CAST(NEW.total*(COALESCE((SELECT CASE level WHEN 'start' THEN 5 WHEN 'progress' THEN 10 WHEN 'power' THEN 25 WHEN 'peak' THEN 50 END FROM bx_customer_levels WHERE customer_id=f.customer_id), CASE
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=80000 THEN 50
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=40000 THEN 25
 WHEN COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id),0)>=15000 THEN 10 ELSE 5 END))/100 AS INTEGER)>0;
END;
-- Автоматическое повышение уровня после доставленного заказа.
CREATE TRIGGER IF NOT EXISTS bx_notify_level_after_delivery AFTER UPDATE OF status ON orders
WHEN OLD.status!='delivered' AND NEW.status='delivered'
 AND COALESCE((SELECT enabled FROM bx_notification_flags WHERE entity_key='order:'||NEW.id),1)=1
BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'level:auto:'||NEW.id,f.customer_id,
 '✦ RULES. CLUB' || char(10) || char(10) || 'Ваш уровень вырос: ' ||
 CASE WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered')>=80000 THEN 'ПИК'
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered')>=40000 THEN 'СИЛА'
 ELSE 'ПРОГРЕСС' END || '!' || char(10) || 'Спасибо, что выбираете RULES.!'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM bx_customer_levels WHERE customer_id=f.customer_id)
 AND ((SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered')>=15000 AND (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id)<15000
 OR (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered')>=40000 AND (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id)<40000
 OR (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered')>=80000 AND (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.id!=NEW.id)<80000);
END;


-- FILE: 0011_reversible_orders.sql
-- RULES.. Выполнять после 0004–0010, только после резервного копирования.
-- Миграция не выполняет банковский возврат и не изменяет существующие заказы.
DROP TRIGGER IF EXISTS bioryx_cancel_guard;
DROP TRIGGER IF EXISTS bioryx_cancel_restock;
DROP TRIGGER IF EXISTS bx_delivered_immutable;
DROP TRIGGER IF EXISTS bx_delivery_guard;
DROP TRIGGER IF EXISTS bx_cancel_points;
DROP TRIGGER IF EXISTS bx_delivery_cashback;
DROP TRIGGER IF EXISTS bx_notify_level_after_delivery;
DROP TRIGGER IF EXISTS bx_notify_ledger;

-- Для возобновления отменённого заказа товар необходимо снова зарезервировать.
CREATE TRIGGER IF NOT EXISTS bx_reopen_stock_guard BEFORE UPDATE OF status ON orders
WHEN OLD.status='cancelled' AND NEW.status!='cancelled' BEGIN
 SELECT CASE WHEN EXISTS(
  SELECT 1 FROM order_items i LEFT JOIN products p ON p.id=i.product_id
  WHERE i.order_id=NEW.id GROUP BY i.product_id
  HAVING p.id IS NULL OR p.stock < SUM(i.qty)
 ) THEN RAISE(ABORT,'insufficient_stock_to_reopen') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_stock_transitions AFTER UPDATE OF status ON orders
WHEN (OLD.status='cancelled' AND NEW.status!='cancelled') OR (OLD.status!='cancelled' AND NEW.status='cancelled') BEGIN
 UPDATE products SET stock=stock + CASE WHEN NEW.status='cancelled' THEN 1 ELSE -1 END *
 (SELECT COALESCE(SUM(qty),0) FROM order_items WHERE order_id=NEW.id AND product_id=products.id)
 WHERE id IN (SELECT product_id FROM order_items WHERE order_id=NEW.id);
END;
-- При отмене/возобновлении приводим фактическое списание к нулю/первоначальной сумме.
CREATE TRIGGER IF NOT EXISTS bx_redemption_transitions AFTER UPDATE OF status ON orders
WHEN (OLD.status='cancelled' AND NEW.status!='cancelled') OR (OLD.status!='cancelled' AND NEW.status='cancelled') BEGIN
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT lower(hex(randomblob(16))),f.customer_id,NEW.id,
 CASE WHEN NEW.status='cancelled' THEN 'restore' ELSE 'redeem' END,
 CASE WHEN NEW.status='cancelled' THEN -COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('redeem','restore')),0)
 ELSE -f.points_used-COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('redeem','restore')),0) END,
 lower(hex(randomblob(16))),CASE WHEN NEW.status='cancelled' THEN 'Возврат баллов после отмены' ELSE 'Повторное списание при возобновлении заказа' END
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND f.points_used>0
 AND CASE WHEN NEW.status='cancelled' THEN -COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('redeem','restore')),0)>0
 ELSE -f.points_used-COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('redeem','restore')),0)<0 END;
END;
-- Уходим из состояния «доставлен и оплачен»: отменяем именно уже начисленный кэшбэк.
CREATE TRIGGER IF NOT EXISTS bx_cashback_reverse AFTER UPDATE OF status,payment_status ON orders
WHEN OLD.status='delivered' AND OLD.payment_status='paid' AND (NEW.status!='delivered' OR NEW.payment_status!='paid') BEGIN
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT lower(hex(randomblob(16))),f.customer_id,NEW.id,'reversal',
 -COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('earn','reversal')),0),
 lower(hex(randomblob(16))),'Корректировка кэшбэка при изменении заказа'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL
 AND COALESCE((SELECT SUM(l.points) FROM bx_loyalty_ledger l WHERE l.order_id=NEW.id AND l.kind IN ('earn','reversal')),0)>0;
END;
-- Входим в состояние «доставлен и оплачен»: начисляем по актуальному уровню.
CREATE TRIGGER IF NOT EXISTS bx_cashback_recalculate AFTER UPDATE OF status,payment_status ON orders
WHEN NEW.status='delivered' AND NEW.payment_status='paid' AND (OLD.status!='delivered' OR OLD.payment_status!='paid') BEGIN
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT lower(hex(randomblob(16))),f.customer_id,NEW.id,'earn',
 CAST(NEW.total * COALESCE((SELECT CASE level WHEN 'start' THEN 5 WHEN 'progress' THEN 10 WHEN 'power' THEN 25 WHEN 'peak' THEN 50 END FROM bx_customer_levels WHERE customer_id=f.customer_id),
 CASE WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=80000 THEN 50
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=40000 THEN 25
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=15000 THEN 10 ELSE 5 END)/100 AS INTEGER),
 lower(hex(randomblob(16))),'Кэшбэк за доставленный и оплаченный заказ'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND
 CAST(NEW.total * COALESCE((SELECT CASE level WHEN 'start' THEN 5 WHEN 'progress' THEN 10 WHEN 'power' THEN 25 WHEN 'peak' THEN 50 END FROM bx_customer_levels WHERE customer_id=f.customer_id),
 CASE WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=80000 THEN 50
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=40000 THEN 25
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id)>=15000 THEN 10 ELSE 5 END)/100 AS INTEGER)>0;
END;
CREATE TRIGGER IF NOT EXISTS bx_notify_ledger AFTER INSERT ON bx_loyalty_ledger
WHEN NEW.kind IN ('welcome','earn','redeem','restore','reversal')
 AND COALESCE((SELECT enabled FROM bx_notification_flags WHERE entity_key='order:'||NEW.order_id),1)=1 BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body) VALUES('ledger:'||NEW.id,NEW.customer_id,
 CASE NEW.kind
 WHEN 'welcome' THEN '✦ RULES. CLUB'||char(10)||char(10)||'Добро пожаловать! Начислено +'||NEW.points||' баллов.'
 WHEN 'earn' THEN '✦ RULES. CLUB'||char(10)||char(10)||'Начислено +'||NEW.points||' баллов за заказ. Спасибо, что выбираете RULES.!'
 WHEN 'redeem' THEN '✦ RULES. CLUB'||char(10)||char(10)||'Списано '||(-NEW.points)||' баллов за заказ.'
 WHEN 'reversal' THEN '✦ RULES. CLUB'||char(10)||char(10)||'После изменения заказа ранее начисленный кэшбэк скорректирован на '||NEW.points||' баллов.'
 ELSE '✦ RULES. CLUB'||char(10)||char(10)||'После отмены заказа возвращено +'||NEW.points||' баллов.' END);
END;
CREATE TRIGGER IF NOT EXISTS bx_auto_level_transitions AFTER UPDATE OF status,payment_status ON orders
WHEN (OLD.status='delivered' AND OLD.payment_status='paid') != (NEW.status='delivered' AND NEW.payment_status='paid')
 AND COALESCE((SELECT enabled FROM bx_notification_flags WHERE entity_key='order:'||NEW.id),1)=1 BEGIN
 INSERT INTO bx_notifications(id,customer_id,body)
 SELECT 'auto-level:'||lower(hex(randomblob(16))),f.customer_id,
 '✦ RULES. CLUB'||char(10)||char(10)||'Ваш уровень обновлён: '||
 CASE WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid')>=80000 THEN 'ПИК'
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid')>=40000 THEN 'СИЛА'
 WHEN (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid')>=15000 THEN 'ПРОГРЕСС' ELSE 'СТАРТ' END||'.'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM bx_customer_levels WHERE customer_id=f.customer_id)
 AND (SELECT COUNT(*) FROM (SELECT 15000 AS threshold UNION ALL SELECT 40000 UNION ALL SELECT 80000) t
 WHERE ((SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid') >= t.threshold) !=
 (((SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid')
 - CASE WHEN NEW.status='delivered' AND NEW.payment_status='paid' THEN NEW.total ELSE 0 END
 + CASE WHEN OLD.status='delivered' AND OLD.payment_status='paid' THEN OLD.total ELSE 0 END) >= t.threshold))>0;
END;


-- FILE: 0012_atomic_notifications.sql
-- RULES.: после миграций 0004–0011. Команды не удаляют данные магазина.
-- Контекст события задаётся и удаляется в одной транзакционной D1 batch.
CREATE TABLE IF NOT EXISTS bx_admin_event_context (
 entity_key TEXT PRIMARY KEY,
 operation_id TEXT NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN ('status','payment','points','level')),
 body TEXT NOT NULL DEFAULT '',
 notify INTEGER NOT NULL DEFAULT 0 CHECK(notify IN (0,1))
);
CREATE TRIGGER IF NOT EXISTS bx_admin_status_notification AFTER UPDATE OF status ON orders
WHEN OLD.status != NEW.status BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'status:'||e.operation_id,x.customer_id,e.body
 FROM bx_admin_event_context e JOIN bx_order_owners x ON x.order_id=NEW.id
 WHERE e.entity_key='order:'||NEW.id AND e.kind='status' AND e.notify=1;
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_payment_notification AFTER UPDATE OF payment,payment_status ON orders
WHEN OLD.payment != NEW.payment OR OLD.payment_status != NEW.payment_status BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'payment:'||e.operation_id,x.customer_id,e.body
 FROM bx_admin_event_context e JOIN bx_order_owners x ON x.order_id=NEW.id
 WHERE e.entity_key='order:'||NEW.id AND e.kind='payment' AND e.notify=1;
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_points_notification AFTER INSERT ON bx_loyalty_ledger
WHEN NEW.kind='adjustment' BEGIN
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'adjustment:'||e.operation_id,NEW.customer_id,e.body FROM bx_admin_event_context e
 WHERE e.entity_key='customer:'||NEW.customer_id AND e.kind='points' AND e.notify=1;
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_level_insert AFTER INSERT ON bx_customer_levels BEGIN
 INSERT INTO bx_level_audit(customer_id,old_level,new_level) VALUES(NEW.customer_id,'auto',NEW.level);
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'level:'||e.operation_id,NEW.customer_id,e.body FROM bx_admin_event_context e
 WHERE e.entity_key='customer:'||NEW.customer_id AND e.kind='level' AND e.notify=1;
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_level_update AFTER UPDATE OF level ON bx_customer_levels
WHEN OLD.level != NEW.level BEGIN
 INSERT INTO bx_level_audit(customer_id,old_level,new_level) VALUES(NEW.customer_id,OLD.level,NEW.level);
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'level:'||e.operation_id,NEW.customer_id,e.body FROM bx_admin_event_context e
 WHERE e.entity_key='customer:'||NEW.customer_id AND e.kind='level' AND e.notify=1;
END;
CREATE TRIGGER IF NOT EXISTS bx_admin_level_delete AFTER DELETE ON bx_customer_levels BEGIN
 INSERT INTO bx_level_audit(customer_id,old_level,new_level) VALUES(OLD.customer_id,OLD.level,'auto');
 INSERT OR IGNORE INTO bx_notifications(id,customer_id,body)
 SELECT 'level:'||e.operation_id,OLD.customer_id,e.body FROM bx_admin_event_context e
 WHERE e.entity_key='customer:'||OLD.customer_id AND e.kind='level' AND e.notify=1;
END;


-- FILE: 0013_club_settings.sql
-- RULES.: выполнять после 0012 и резервного копирования. Действующие настройки по умолчанию не изменяются.
CREATE TABLE IF NOT EXISTS bx_club_levels (
 id TEXT PRIMARY KEY CHECK(id IN ('start','progress','power','peak')),
 title TEXT NOT NULL CHECK(length(title) BETWEEN 1 AND 60),
 threshold INTEGER NOT NULL CHECK(threshold>=0),
 cashback INTEGER NOT NULL CHECK(cashback BETWEEN 0 AND 100)
);
INSERT OR IGNORE INTO bx_club_levels(id,title,threshold,cashback) VALUES
 ('start','СТАРТ',0,5),('progress','ПРОГРЕСС',15000,10),('power','СИЛА',40000,25),('peak','ПИК',80000,50);
CREATE TABLE IF NOT EXISTS bx_club_settings (id INTEGER PRIMARY KEY CHECK(id=1),redeem_percent INTEGER NOT NULL CHECK(redeem_percent BETWEEN 0 AND 100));
INSERT OR IGNORE INTO bx_club_settings(id,redeem_percent) VALUES(1,100);
CREATE TABLE IF NOT EXISTS bx_club_settings_audit (id INTEGER PRIMARY KEY AUTOINCREMENT, snapshot TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT(datetime('now')));
DROP TRIGGER IF EXISTS bx_club_redeem_limit;
CREATE TRIGGER bx_club_redeem_limit BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NEW.points_used > CAST((NEW.gross-NEW.discount)*COALESCE((SELECT redeem_percent FROM bx_club_settings WHERE id=1),100)/100 AS INTEGER) THEN RAISE(ABORT,'club_redeem_limit') END;
END;
DROP TRIGGER IF EXISTS bx_cashback_recalculate;
CREATE TRIGGER bx_cashback_recalculate AFTER UPDATE OF status,payment_status ON orders
WHEN NEW.status='delivered' AND NEW.payment_status='paid' AND (OLD.status!='delivered' OR OLD.payment_status!='paid') BEGIN
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT lower(hex(randomblob(16))),f.customer_id,NEW.id,'earn',CAST(NEW.total * COALESCE(
 (SELECT l.cashback FROM bx_customer_levels x JOIN bx_club_levels l ON l.id=x.level WHERE x.customer_id=f.customer_id),
 (SELECT l.cashback FROM bx_club_levels l WHERE l.threshold <= (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id) ORDER BY l.threshold DESC LIMIT 1),0)/100 AS INTEGER),lower(hex(randomblob(16))),'Кэшбэк за доставленный и оплаченный заказ'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND CAST(NEW.total * COALESCE(
 (SELECT l.cashback FROM bx_customer_levels x JOIN bx_club_levels l ON l.id=x.level WHERE x.customer_id=f.customer_id),
 (SELECT l.cashback FROM bx_club_levels l WHERE l.threshold <= (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.id) ORDER BY l.threshold DESC LIMIT 1),0)/100 AS INTEGER)>0;
END;
DROP TRIGGER IF EXISTS bx_auto_level_transitions;
CREATE TRIGGER bx_auto_level_transitions AFTER UPDATE OF status,payment_status ON orders
WHEN (OLD.status='delivered' AND OLD.payment_status='paid') != (NEW.status='delivered' AND NEW.payment_status='paid')
 AND COALESCE((SELECT enabled FROM bx_notification_flags WHERE entity_key='order:'||NEW.id),1)=1 BEGIN
 INSERT INTO bx_notifications(id,customer_id,body)
 SELECT 'auto-level:'||lower(hex(randomblob(16))),f.customer_id,'✦ RULES. CLUB'||char(10)||char(10)||'Ваш уровень обновлён: '||
 (SELECT title FROM bx_club_levels WHERE threshold <= (SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid') ORDER BY threshold DESC LIMIT 1)||'.'
 FROM bx_order_finance f WHERE f.order_id=NEW.id AND f.customer_id IS NOT NULL AND NOT EXISTS(SELECT 1 FROM bx_customer_levels WHERE customer_id=f.customer_id)
 AND (SELECT COUNT(*) FROM bx_club_levels t WHERE t.threshold>0 AND
 ((SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid')>=t.threshold) !=
 (((SELECT COALESCE(SUM(o.total),0) FROM orders o JOIN bx_order_finance x ON x.order_id=o.id WHERE x.customer_id=f.customer_id AND o.status='delivered' AND o.payment_status='paid') - CASE WHEN NEW.status='delivered' AND NEW.payment_status='paid' THEN NEW.total ELSE 0 END + CASE WHEN OLD.status='delivered' AND OLD.payment_status='paid' THEN OLD.total ELSE 0 END)>=t.threshold))>0;
END;


-- FILE: 0014_promo_rules.sql
-- RULES.: после 0013. Существующие промокоды без записи в bx_promo_rules работают без ограничений.
-- Даты — календарные даты UTC включительно. Применение считается навсегда, даже при отмене.
CREATE TABLE IF NOT EXISTS bx_promo_rules (
 code TEXT PRIMARY KEY REFERENCES bx_promos(code),
 start_date TEXT NOT NULL DEFAULT '',
 end_date TEXT NOT NULL DEFAULT '',
 min_goods INTEGER NOT NULL DEFAULT 0 CHECK(min_goods>=0),
 max_uses INTEGER NOT NULL DEFAULT 0 CHECK(max_uses>=0),
 updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_finance_promo_code ON bx_order_finance(promo_code);
CREATE TRIGGER IF NOT EXISTS bx_promo_conditions_guard BEFORE INSERT ON bx_order_finance
WHEN NEW.promo_code!='' BEGIN
 SELECT CASE WHEN EXISTS (SELECT 1 FROM bx_promo_rules r WHERE r.code=NEW.promo_code AND (
  (r.start_date!='' AND date('now')<r.start_date) OR
  (r.end_date!='' AND date('now')>r.end_date) OR
  NEW.gross<r.min_goods OR
  (r.max_uses>0 AND (SELECT count(*) FROM bx_order_finance f WHERE f.promo_code=NEW.promo_code)>=r.max_uses)
 )) THEN RAISE(ABORT,'promo_conditions_failed') END;
END;


-- FILE: 0015_fixed_promos.sql
-- RULES.: после 0014. Отсутствие строки bx_promo_amounts означает прежнюю процентную скидку.
CREATE TABLE IF NOT EXISTS bx_promo_amounts (
 code TEXT PRIMARY KEY REFERENCES bx_promos(code),
 amount INTEGER NOT NULL CHECK(amount BETWEEN 1 AND 10000000)
);
CREATE TABLE IF NOT EXISTS bx_promo_order_snapshots (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 kind TEXT NOT NULL CHECK(kind IN ('percent','fixed')),
 value INTEGER NOT NULL CHECK(value>=1)
);
DROP TRIGGER IF EXISTS bx_finance_guard;
CREATE TRIGGER bx_finance_guard BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM orders WHERE id=NEW.order_id AND total=NEW.gross AND status='new') THEN RAISE(ABORT,'bad_gross') END;
 SELECT CASE WHEN NEW.promo_code='' AND (NEW.promo_percent!=0 OR NEW.discount!=0) THEN RAISE(ABORT,'bad_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NOT EXISTS(
  SELECT 1 FROM bx_promos p LEFT JOIN bx_promo_amounts a ON a.code=p.code
  WHERE p.code=NEW.promo_code AND p.active=1 AND ((a.code IS NULL AND p.percent=NEW.promo_percent) OR (a.code IS NOT NULL AND NEW.promo_percent=0))
 ) THEN RAISE(ABORT,'invalid_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NEW.discount != COALESCE(
  (SELECT min(NEW.gross,a.amount) FROM bx_promo_amounts a WHERE a.code=NEW.promo_code),
  CAST(NEW.gross*NEW.promo_percent/100 AS INTEGER)
 ) THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>NEW.gross-NEW.discount THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>0 AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id)) THEN RAISE(ABORT,'customer_required') END;
 SELECT CASE WHEN NEW.points_used>0 AND NEW.points_used > COALESCE((SELECT SUM(points) FROM bx_loyalty_ledger WHERE customer_id=NEW.customer_id),0) THEN RAISE(ABORT,'insufficient_points') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_promo_snapshot AFTER INSERT ON bx_order_finance WHEN NEW.promo_code!='' BEGIN
 INSERT INTO bx_promo_order_snapshots(order_id,kind,value)
 SELECT NEW.order_id,CASE WHEN a.code IS NULL THEN 'percent' ELSE 'fixed' END,COALESCE(a.amount,NEW.promo_percent)
 FROM bx_promos p LEFT JOIN bx_promo_amounts a ON a.code=p.code WHERE p.code=NEW.promo_code;
END;


-- FILE: 0016_promo_gifts.sql
-- RULES., после 0015. Снимки подарков привязаны к заказам и не меняются при редактировании акции.
CREATE TABLE IF NOT EXISTS bx_promo_no_discount (code TEXT PRIMARY KEY REFERENCES bx_promos(code));
CREATE TABLE IF NOT EXISTS bx_promo_gifts (
 code TEXT PRIMARY KEY REFERENCES bx_promos(code), product_id TEXT NOT NULL DEFAULT '',
 qty INTEGER NOT NULL DEFAULT 0 CHECK(qty BETWEEN 0 AND 20), description TEXT NOT NULL DEFAULT '',
 CHECK((product_id='' AND qty=0) OR (product_id!='' AND qty BETWEEN 1 AND 20)),
 CHECK(product_id!='' OR length(description)>0)
);
CREATE TABLE IF NOT EXISTS bx_promo_expectations (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),code TEXT NOT NULL,product_id TEXT NOT NULL,qty INTEGER NOT NULL,description TEXT NOT NULL, no_discount INTEGER NOT NULL CHECK(no_discount IN (0,1))
);
CREATE TABLE IF NOT EXISTS bx_order_gifts (
 order_id TEXT PRIMARY KEY REFERENCES orders(id), product_id TEXT NOT NULL DEFAULT '',
 product_name TEXT NOT NULL DEFAULT '', qty INTEGER NOT NULL DEFAULT 0, description TEXT NOT NULL DEFAULT ''
);
DROP TRIGGER IF EXISTS bx_finance_guard;
CREATE TRIGGER bx_finance_guard BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM orders WHERE id=NEW.order_id AND total=NEW.gross AND status='new') THEN RAISE(ABORT,'bad_gross') END;
 SELECT CASE WHEN NEW.promo_code='' AND (NEW.promo_percent!=0 OR NEW.discount!=0) THEN RAISE(ABORT,'bad_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NOT EXISTS(
 SELECT 1 FROM bx_promos p LEFT JOIN bx_promo_amounts a ON a.code=p.code LEFT JOIN bx_promo_no_discount n ON n.code=p.code
 WHERE p.code=NEW.promo_code AND p.active=1 AND ((n.code IS NOT NULL AND a.code IS NULL AND NEW.promo_percent=0) OR (n.code IS NULL AND a.code IS NOT NULL AND NEW.promo_percent=0) OR (n.code IS NULL AND a.code IS NULL AND p.percent=NEW.promo_percent))
 ) THEN RAISE(ABORT,'invalid_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NEW.discount != CASE WHEN EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) THEN 0 ELSE COALESCE((SELECT min(NEW.gross,a.amount) FROM bx_promo_amounts a WHERE a.code=NEW.promo_code),CAST(NEW.gross*NEW.promo_percent/100 AS INTEGER)) END THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>NEW.gross-NEW.discount THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>0 AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id)) THEN RAISE(ABORT,'customer_required') END;
 SELECT CASE WHEN NEW.points_used>0 AND NEW.points_used > COALESCE((SELECT SUM(points) FROM bx_loyalty_ledger WHERE customer_id=NEW.customer_id),0) THEN RAISE(ABORT,'insufficient_points') END;
 SELECT CASE WHEN NEW.promo_code!='' AND (EXISTS(SELECT 1 FROM bx_promo_gifts WHERE code=NEW.promo_code) OR EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) OR EXISTS(SELECT 1 FROM bx_promo_expectations WHERE order_id=NEW.order_id)) AND NOT EXISTS (
 SELECT 1 FROM bx_promo_expectations e LEFT JOIN bx_promo_gifts g ON g.code=NEW.promo_code LEFT JOIN bx_promo_no_discount n ON n.code=NEW.promo_code
 WHERE e.order_id=NEW.order_id AND e.code=NEW.promo_code AND e.product_id=COALESCE(g.product_id,'') AND e.qty=COALESCE(g.qty,0) AND e.description=COALESCE(g.description,'') AND e.no_discount=CASE WHEN n.code IS NULL THEN 0 ELSE 1 END
 ) THEN RAISE(ABORT,'promo_gift_changed') END;
END;
DROP TRIGGER IF EXISTS bx_promo_snapshot;
CREATE TRIGGER bx_promo_snapshot AFTER INSERT ON bx_order_finance WHEN NEW.promo_code!='' AND NOT EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) BEGIN
 INSERT INTO bx_promo_order_snapshots(order_id,kind,value) SELECT NEW.order_id,CASE WHEN a.code IS NULL THEN 'percent' ELSE 'fixed' END,COALESCE(a.amount,NEW.promo_percent) FROM bx_promos p LEFT JOIN bx_promo_amounts a ON a.code=p.code WHERE p.code=NEW.promo_code;
END;
CREATE TRIGGER IF NOT EXISTS bx_promo_gift_add AFTER INSERT ON bx_order_finance WHEN NEW.promo_code!='' BEGIN
 INSERT INTO bx_order_gifts(order_id,product_id,product_name,qty,description)
 SELECT NEW.order_id,g.product_id,COALESCE((SELECT name FROM products WHERE id=g.product_id),''),g.qty,g.description FROM bx_promo_gifts g WHERE g.code=NEW.promo_code;
END;
CREATE TRIGGER IF NOT EXISTS bx_gift_reserve_guard BEFORE INSERT ON bx_order_gifts WHEN NEW.product_id!='' BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM products WHERE id=NEW.product_id AND active=1 AND stock>=NEW.qty AND name=NEW.product_name) THEN RAISE(ABORT,'gift_unavailable') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_gift_reserve AFTER INSERT ON bx_order_gifts WHEN NEW.product_id!='' BEGIN
 UPDATE products SET stock=stock-NEW.qty WHERE id=NEW.product_id;
END;
-- Проверяется совокупный остаток подарка и всех купленных единиц того же товара.
CREATE TRIGGER IF NOT EXISTS bx_gift_reopen_guard BEFORE UPDATE OF status ON orders WHEN OLD.status='cancelled' AND NEW.status!='cancelled' BEGIN
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_order_gifts g LEFT JOIN products p ON p.id=g.product_id WHERE g.order_id=NEW.id AND g.product_id!='' AND (p.id IS NULL OR p.stock < g.qty+COALESCE((SELECT sum(i.qty) FROM order_items i WHERE i.order_id=NEW.id AND i.product_id=g.product_id),0))) THEN RAISE(ABORT,'insufficient_stock_to_reopen_gift') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_gift_stock_transitions AFTER UPDATE OF status ON orders WHEN (OLD.status='cancelled' AND NEW.status!='cancelled') OR (OLD.status!='cancelled' AND NEW.status='cancelled') BEGIN
 UPDATE products SET stock=stock+CASE WHEN NEW.status='cancelled' THEN 1 ELSE -1 END*(SELECT g.qty FROM bx_order_gifts g WHERE g.order_id=NEW.id AND g.product_id=products.id) WHERE id IN (SELECT product_id FROM bx_order_gifts WHERE order_id=NEW.id AND product_id!='');
END;


-- FILE: 0017_free_shipping.sql
-- RULES.: после 0016. Доставка по-прежнему рассчитывается вручную, кроме зафиксированного преимущества.
CREATE TABLE IF NOT EXISTS bx_promo_shipping (
 code TEXT PRIMARY KEY REFERENCES bx_promos(code),
 methods TEXT NOT NULL CHECK(methods IN ('courier','cdek','both'))
);
CREATE TABLE IF NOT EXISTS bx_shipping_expectations (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 code TEXT NOT NULL, methods TEXT NOT NULL CHECK(methods IN ('','courier','cdek','both'))
);
CREATE TABLE IF NOT EXISTS bx_order_shipping_benefits (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 code TEXT NOT NULL, delivery TEXT NOT NULL,
 methods TEXT NOT NULL CHECK(methods IN ('courier','cdek','both')),
 free_shipping INTEGER NOT NULL CHECK(free_shipping IN (0,1))
);
CREATE TRIGGER IF NOT EXISTS bx_shipping_conditions_guard BEFORE INSERT ON bx_order_finance WHEN NEW.promo_code!='' BEGIN
 -- Защищает от изменений условий после предварительного расчёта; старые коды без доставки не требуют контекста.
 SELECT CASE WHEN (EXISTS(SELECT 1 FROM bx_promo_shipping WHERE code=NEW.promo_code) OR EXISTS(SELECT 1 FROM bx_shipping_expectations WHERE order_id=NEW.order_id)) AND NOT EXISTS(
 SELECT 1 FROM bx_shipping_expectations e LEFT JOIN bx_promo_shipping s ON s.code=NEW.promo_code
 WHERE e.order_id=NEW.order_id AND e.code=NEW.promo_code AND e.methods=COALESCE(s.methods,'')
 ) THEN RAISE(ABORT,'promo_shipping_changed') END;
 -- Если акция без скидки не имеет подарка, она должна действительно давать бесплатную доставку.
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) AND NOT EXISTS(SELECT 1 FROM bx_promo_gifts WHERE code=NEW.promo_code) AND NOT EXISTS(
 SELECT 1 FROM bx_promo_shipping s JOIN orders o ON o.id=NEW.order_id WHERE s.code=NEW.promo_code AND ((s.methods='both' AND o.delivery IN ('courier','cdek')) OR s.methods=o.delivery)
 ) THEN RAISE(ABORT,'promo_shipping_not_applicable') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_shipping_benefit_snapshot AFTER INSERT ON bx_order_finance WHEN NEW.promo_code!='' BEGIN
 INSERT INTO bx_order_shipping_benefits(order_id,code,delivery,methods,free_shipping)
 SELECT NEW.order_id,NEW.promo_code,o.delivery,s.methods,CASE WHEN (s.methods='both' AND o.delivery IN ('courier','cdek')) OR s.methods=o.delivery THEN 1 ELSE 0 END
 FROM bx_promo_shipping s JOIN orders o ON o.id=NEW.order_id WHERE s.code=NEW.promo_code;
END;


-- FILE: 0018_promo_club_access.sql
-- RULES.: после 0017. Если уровни не указаны, акция публичная.
CREATE TABLE IF NOT EXISTS bx_promo_levels (
 code TEXT NOT NULL REFERENCES bx_promos(code),
 level TEXT NOT NULL REFERENCES bx_club_levels(id),
 PRIMARY KEY(code,level)
);
CREATE TABLE IF NOT EXISTS bx_order_promo_access (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 code TEXT NOT NULL,
 customer_id TEXT NOT NULL REFERENCES bx_customers(id),
 level TEXT NOT NULL
);
CREATE TRIGGER IF NOT EXISTS bx_promo_level_guard BEFORE INSERT ON bx_order_finance
WHEN NEW.promo_code!='' AND EXISTS(SELECT 1 FROM bx_promo_levels WHERE code=NEW.promo_code) BEGIN
 SELECT CASE WHEN NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id) OR NOT EXISTS(
  SELECT 1 FROM bx_promo_levels a WHERE a.code=NEW.promo_code AND a.level=COALESCE(
   (SELECT level FROM bx_customer_levels WHERE customer_id=NEW.customer_id),
   (SELECT l.id FROM bx_club_levels l WHERE l.threshold<=COALESCE((SELECT sum(o.total) FROM orders o JOIN bx_order_finance f ON f.order_id=o.id WHERE f.customer_id=NEW.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.order_id),0) ORDER BY l.threshold DESC LIMIT 1)
  )
 ) THEN RAISE(ABORT,'promo_level_not_allowed') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_promo_level_snapshot AFTER INSERT ON bx_order_finance
WHEN NEW.promo_code!='' AND EXISTS(SELECT 1 FROM bx_promo_levels WHERE code=NEW.promo_code) BEGIN
 INSERT INTO bx_order_promo_access(order_id,code,customer_id,level)
 SELECT NEW.order_id,NEW.promo_code,NEW.customer_id,COALESCE(
  (SELECT level FROM bx_customer_levels WHERE customer_id=NEW.customer_id),
  (SELECT l.id FROM bx_club_levels l WHERE l.threshold<=COALESCE((SELECT sum(o.total) FROM orders o JOIN bx_order_finance f ON f.order_id=o.id WHERE f.customer_id=NEW.customer_id AND o.status='delivered' AND o.payment_status='paid' AND o.id!=NEW.order_id),0) ORDER BY l.threshold DESC LIMIT 1)
 );
END;


-- FILE: 0019_club_sale_prices.sql
-- RULES.: после 0018. Закрытая цена — для конкретного товара и конкретного уровня.
CREATE TABLE IF NOT EXISTS bx_club_sale_prices (
 product_id TEXT NOT NULL REFERENCES products(id),level TEXT NOT NULL REFERENCES bx_club_levels(id),
 sale_price INTEGER NOT NULL CHECK(sale_price BETWEEN 1 AND 10000000),
 start_date TEXT NOT NULL DEFAULT '',end_date TEXT NOT NULL DEFAULT '',
 active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1)),updated_at TEXT NOT NULL DEFAULT(datetime('now')),
 PRIMARY KEY(product_id,level)
);
CREATE TABLE IF NOT EXISTS bx_order_sale_lines (
 order_id TEXT NOT NULL REFERENCES orders(id),product_id TEXT NOT NULL,level TEXT NOT NULL,
 base_price INTEGER NOT NULL CHECK(base_price>0),sale_price INTEGER NOT NULL CHECK(sale_price>0 AND sale_price<base_price),qty INTEGER NOT NULL CHECK(qty BETWEEN 1 AND 20),
 PRIMARY KEY(order_id,product_id)
);
CREATE TRIGGER IF NOT EXISTS bx_sale_line_guard BEFORE INSERT ON bx_order_sale_lines BEGIN
 SELECT CASE WHEN NOT EXISTS(
 SELECT 1 FROM order_items i JOIN products p ON p.id=i.product_id JOIN bx_order_owners ow ON ow.order_id=i.order_id
 JOIN bx_club_sale_prices s ON s.product_id=i.product_id AND s.level=NEW.level
 WHERE i.order_id=NEW.order_id AND i.product_id=NEW.product_id AND i.price=NEW.base_price AND i.qty=NEW.qty AND p.price=NEW.base_price AND p.active=1
 AND s.active=1 AND s.sale_price=NEW.sale_price AND s.sale_price<p.price
 AND (s.start_date='' OR date('now')>=s.start_date) AND (s.end_date='' OR date('now')<=s.end_date)
 AND s.level=COALESCE((SELECT level FROM bx_customer_levels WHERE customer_id=ow.customer_id),
 (SELECT l.id FROM bx_club_levels l WHERE l.threshold<=COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance f ON f.order_id=o.id WHERE f.customer_id=ow.customer_id AND o.status='delivered' AND o.payment_status='paid'),0) ORDER BY l.threshold DESC LIMIT 1))
 ) THEN RAISE(ABORT,'club_sale_changed') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_sale_finance_guard BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_order_sale_lines WHERE order_id=NEW.order_id) AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id)) THEN RAISE(ABORT,'club_sale_customer_required') END;
 SELECT CASE WHEN EXISTS(
 SELECT 1 FROM order_items i JOIN products p ON p.id=i.product_id JOIN bx_order_owners ow ON ow.order_id=i.order_id
 JOIN bx_club_sale_prices s ON s.product_id=i.product_id
 WHERE i.order_id=NEW.order_id AND s.active=1 AND s.sale_price<p.price
 AND (s.start_date='' OR date('now')>=s.start_date) AND (s.end_date='' OR date('now')<=s.end_date)
 AND s.level=COALESCE((SELECT level FROM bx_customer_levels WHERE customer_id=ow.customer_id),
 (SELECT l.id FROM bx_club_levels l WHERE l.threshold<=COALESCE((SELECT SUM(o.total) FROM orders o JOIN bx_order_finance f ON f.order_id=o.id WHERE f.customer_id=ow.customer_id AND o.status='delivered' AND o.payment_status='paid'),0) ORDER BY l.threshold DESC LIMIT 1))
 AND NOT EXISTS(SELECT 1 FROM bx_order_sale_lines x WHERE x.order_id=i.order_id AND x.product_id=i.product_id AND x.sale_price=s.sale_price AND x.base_price=i.price AND x.qty=i.qty AND x.level=s.level)
 ) THEN RAISE(ABORT,'club_sale_quote_missing') END;
END;

DROP TRIGGER IF EXISTS bx_finance_guard;
CREATE TRIGGER bx_finance_guard BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM orders WHERE id=NEW.order_id AND total=NEW.gross AND status='new') THEN RAISE(ABORT,'bad_gross') END;
 SELECT CASE WHEN NEW.promo_code='' AND (NEW.promo_percent!=0 OR NEW.discount!=0) THEN RAISE(ABORT,'bad_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NOT EXISTS(
 SELECT 1 FROM bx_promos p LEFT JOIN bx_promo_amounts a ON a.code=p.code LEFT JOIN bx_promo_no_discount n ON n.code=p.code
 WHERE p.code=NEW.promo_code AND p.active=1 AND ((n.code IS NOT NULL AND a.code IS NULL AND NEW.promo_percent=0) OR (n.code IS NULL AND a.code IS NOT NULL AND NEW.promo_percent=0) OR (n.code IS NULL AND a.code IS NULL AND p.percent=NEW.promo_percent))
 ) THEN RAISE(ABORT,'invalid_promo') END;
 SELECT CASE WHEN NEW.promo_code!='' AND NEW.discount != CASE WHEN EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) THEN 0 ELSE COALESCE((SELECT min((NEW.gross-COALESCE((SELECT SUM((x.base_price-x.sale_price)*x.qty) FROM bx_order_sale_lines x WHERE x.order_id=NEW.order_id),0)),a.amount) FROM bx_promo_amounts a WHERE a.code=NEW.promo_code),CAST((NEW.gross-COALESCE((SELECT SUM((x.base_price-x.sale_price)*x.qty) FROM bx_order_sale_lines x WHERE x.order_id=NEW.order_id),0))*NEW.promo_percent/100 AS INTEGER)) END THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>(NEW.gross-COALESCE((SELECT SUM((x.base_price-x.sale_price)*x.qty) FROM bx_order_sale_lines x WHERE x.order_id=NEW.order_id),0))-NEW.discount THEN RAISE(ABORT,'bad_discount') END;
 SELECT CASE WHEN NEW.points_used>0 AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners WHERE order_id=NEW.order_id AND customer_id=NEW.customer_id)) THEN RAISE(ABORT,'customer_required') END;
 SELECT CASE WHEN NEW.points_used>0 AND NEW.points_used > COALESCE((SELECT SUM(points) FROM bx_loyalty_ledger WHERE customer_id=NEW.customer_id),0) THEN RAISE(ABORT,'insufficient_points') END;
 SELECT CASE WHEN NEW.promo_code!='' AND (EXISTS(SELECT 1 FROM bx_promo_gifts WHERE code=NEW.promo_code) OR EXISTS(SELECT 1 FROM bx_promo_no_discount WHERE code=NEW.promo_code) OR EXISTS(SELECT 1 FROM bx_promo_expectations WHERE order_id=NEW.order_id)) AND NOT EXISTS (
 SELECT 1 FROM bx_promo_expectations e LEFT JOIN bx_promo_gifts g ON g.code=NEW.promo_code LEFT JOIN bx_promo_no_discount n ON n.code=NEW.promo_code
 WHERE e.order_id=NEW.order_id AND e.code=NEW.promo_code AND e.product_id=COALESCE(g.product_id,'') AND e.qty=COALESCE(g.qty,0) AND e.description=COALESCE(g.description,'') AND e.no_discount=CASE WHEN n.code IS NULL THEN 0 ELSE 1 END
 ) THEN RAISE(ABORT,'promo_gift_changed') END;
END;

DROP TRIGGER IF EXISTS bx_club_redeem_limit;
CREATE TRIGGER bx_club_redeem_limit BEFORE INSERT ON bx_order_finance BEGIN
 SELECT CASE WHEN NEW.points_used>CAST(((NEW.gross-COALESCE((SELECT SUM((x.base_price-x.sale_price)*x.qty) FROM bx_order_sale_lines x WHERE x.order_id=NEW.order_id),0))-NEW.discount)*COALESCE((SELECT redeem_percent FROM bx_club_settings WHERE id=1),100)/100 AS INTEGER) THEN RAISE(ABORT,'club_redeem_limit') END;
END;
DROP TRIGGER IF EXISTS bx_finance_apply;
CREATE TRIGGER bx_finance_apply AFTER INSERT ON bx_order_finance BEGIN
 UPDATE orders SET total=(NEW.gross-COALESCE((SELECT SUM((x.base_price-x.sale_price)*x.qty) FROM bx_order_sale_lines x WHERE x.order_id=NEW.order_id),0))-NEW.discount-NEW.points_used WHERE id=NEW.order_id;
 INSERT INTO bx_loyalty_ledger(id,customer_id,order_id,kind,points,operation_key,note)
 SELECT 'redeem:'||NEW.order_id,NEW.customer_id,NEW.order_id,'redeem',-NEW.points_used,'redeem:'||NEW.order_id,'Оплата баллами' WHERE NEW.points_used>0;
END;


-- FILE: 0020_config_audit.sql
-- RULES.: после 0019. Журнал начинается с момента установки этой миграции.
-- Триггеры выполняются в транзакции изменения; отдельные пользователи-администраторы не различаются.
CREATE TABLE IF NOT EXISTS bx_config_audit (
 id INTEGER PRIMARY KEY AUTOINCREMENT, created_at TEXT NOT NULL DEFAULT(datetime('now')),
 module TEXT NOT NULL, entity TEXT NOT NULL, entity_key TEXT NOT NULL,
 action TEXT NOT NULL CHECK(action IN ('insert','update','delete')),
 old_json TEXT, new_json TEXT
);
CREATE INDEX IF NOT EXISTS bx_config_audit_module_id ON bx_config_audit(module,id DESC);

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promos_insert AFTER INSERT ON bx_promos BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promos',NEW.code,'insert',NULL,json_object('code',NEW.code,'title',NEW.title,'percent',NEW.percent,'active',NEW.active));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promos_update AFTER UPDATE ON bx_promos WHEN OLD.code IS NOT NEW.code OR OLD.title IS NOT NEW.title OR OLD.percent IS NOT NEW.percent OR OLD.active IS NOT NEW.active BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promos',NEW.code,'update',json_object('code',OLD.code,'title',OLD.title,'percent',OLD.percent,'active',OLD.active),json_object('code',NEW.code,'title',NEW.title,'percent',NEW.percent,'active',NEW.active));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promos_delete AFTER DELETE ON bx_promos BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promos',OLD.code,'delete',json_object('code',OLD.code,'title',OLD.title,'percent',OLD.percent,'active',OLD.active),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_rules_insert AFTER INSERT ON bx_promo_rules BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_rules',NEW.code,'insert',NULL,json_object('code',NEW.code,'start_date',NEW.start_date,'end_date',NEW.end_date,'min_goods',NEW.min_goods,'max_uses',NEW.max_uses));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_rules_update AFTER UPDATE ON bx_promo_rules WHEN OLD.code IS NOT NEW.code OR OLD.start_date IS NOT NEW.start_date OR OLD.end_date IS NOT NEW.end_date OR OLD.min_goods IS NOT NEW.min_goods OR OLD.max_uses IS NOT NEW.max_uses BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_rules',NEW.code,'update',json_object('code',OLD.code,'start_date',OLD.start_date,'end_date',OLD.end_date,'min_goods',OLD.min_goods,'max_uses',OLD.max_uses),json_object('code',NEW.code,'start_date',NEW.start_date,'end_date',NEW.end_date,'min_goods',NEW.min_goods,'max_uses',NEW.max_uses));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_rules_delete AFTER DELETE ON bx_promo_rules BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_rules',OLD.code,'delete',json_object('code',OLD.code,'start_date',OLD.start_date,'end_date',OLD.end_date,'min_goods',OLD.min_goods,'max_uses',OLD.max_uses),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_amounts_insert AFTER INSERT ON bx_promo_amounts BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_amounts',NEW.code,'insert',NULL,json_object('code',NEW.code,'amount',NEW.amount));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_amounts_update AFTER UPDATE ON bx_promo_amounts WHEN OLD.code IS NOT NEW.code OR OLD.amount IS NOT NEW.amount BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_amounts',NEW.code,'update',json_object('code',OLD.code,'amount',OLD.amount),json_object('code',NEW.code,'amount',NEW.amount));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_amounts_delete AFTER DELETE ON bx_promo_amounts BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_amounts',OLD.code,'delete',json_object('code',OLD.code,'amount',OLD.amount),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_no_discount_insert AFTER INSERT ON bx_promo_no_discount BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_no_discount',NEW.code,'insert',NULL,json_object('code',NEW.code));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_no_discount_update AFTER UPDATE ON bx_promo_no_discount WHEN OLD.code IS NOT NEW.code BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_no_discount',NEW.code,'update',json_object('code',OLD.code),json_object('code',NEW.code));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_no_discount_delete AFTER DELETE ON bx_promo_no_discount BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_no_discount',OLD.code,'delete',json_object('code',OLD.code),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_gifts_insert AFTER INSERT ON bx_promo_gifts BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_gifts',NEW.code,'insert',NULL,json_object('code',NEW.code,'product_id',NEW.product_id,'qty',NEW.qty,'description',NEW.description));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_gifts_update AFTER UPDATE ON bx_promo_gifts WHEN OLD.code IS NOT NEW.code OR OLD.product_id IS NOT NEW.product_id OR OLD.qty IS NOT NEW.qty OR OLD.description IS NOT NEW.description BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_gifts',NEW.code,'update',json_object('code',OLD.code,'product_id',OLD.product_id,'qty',OLD.qty,'description',OLD.description),json_object('code',NEW.code,'product_id',NEW.product_id,'qty',NEW.qty,'description',NEW.description));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_gifts_delete AFTER DELETE ON bx_promo_gifts BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_gifts',OLD.code,'delete',json_object('code',OLD.code,'product_id',OLD.product_id,'qty',OLD.qty,'description',OLD.description),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_shipping_insert AFTER INSERT ON bx_promo_shipping BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_shipping',NEW.code,'insert',NULL,json_object('code',NEW.code,'methods',NEW.methods));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_shipping_update AFTER UPDATE ON bx_promo_shipping WHEN OLD.code IS NOT NEW.code OR OLD.methods IS NOT NEW.methods BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_shipping',NEW.code,'update',json_object('code',OLD.code,'methods',OLD.methods),json_object('code',NEW.code,'methods',NEW.methods));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_shipping_delete AFTER DELETE ON bx_promo_shipping BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_shipping',OLD.code,'delete',json_object('code',OLD.code,'methods',OLD.methods),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_levels_insert AFTER INSERT ON bx_promo_levels BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_levels',NEW.code||':'||NEW.level,'insert',NULL,json_object('code',NEW.code,'level',NEW.level));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_levels_update AFTER UPDATE ON bx_promo_levels WHEN OLD.code IS NOT NEW.code OR OLD.level IS NOT NEW.level BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_levels',NEW.code||':'||NEW.level,'update',json_object('code',OLD.code,'level',OLD.level),json_object('code',NEW.code,'level',NEW.level));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_promo_levels_delete AFTER DELETE ON bx_promo_levels BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_levels',OLD.code||':'||OLD.level,'delete',json_object('code',OLD.code,'level',OLD.level),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_sale_prices_insert AFTER INSERT ON bx_club_sale_prices BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('sale','bx_club_sale_prices',NEW.product_id||':'||NEW.level,'insert',NULL,json_object('product_id',NEW.product_id,'level',NEW.level,'sale_price',NEW.sale_price,'start_date',NEW.start_date,'end_date',NEW.end_date,'active',NEW.active));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_sale_prices_update AFTER UPDATE ON bx_club_sale_prices WHEN OLD.product_id IS NOT NEW.product_id OR OLD.level IS NOT NEW.level OR OLD.sale_price IS NOT NEW.sale_price OR OLD.start_date IS NOT NEW.start_date OR OLD.end_date IS NOT NEW.end_date OR OLD.active IS NOT NEW.active BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('sale','bx_club_sale_prices',NEW.product_id||':'||NEW.level,'update',json_object('product_id',OLD.product_id,'level',OLD.level,'sale_price',OLD.sale_price,'start_date',OLD.start_date,'end_date',OLD.end_date,'active',OLD.active),json_object('product_id',NEW.product_id,'level',NEW.level,'sale_price',NEW.sale_price,'start_date',NEW.start_date,'end_date',NEW.end_date,'active',NEW.active));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_sale_prices_delete AFTER DELETE ON bx_club_sale_prices BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('sale','bx_club_sale_prices',OLD.product_id||':'||OLD.level,'delete',json_object('product_id',OLD.product_id,'level',OLD.level,'sale_price',OLD.sale_price,'start_date',OLD.start_date,'end_date',OLD.end_date,'active',OLD.active),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_levels_insert AFTER INSERT ON bx_club_levels BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_levels',NEW.id,'insert',NULL,json_object('id',NEW.id,'title',NEW.title,'threshold',NEW.threshold,'cashback',NEW.cashback));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_levels_update AFTER UPDATE ON bx_club_levels WHEN OLD.id IS NOT NEW.id OR OLD.title IS NOT NEW.title OR OLD.threshold IS NOT NEW.threshold OR OLD.cashback IS NOT NEW.cashback BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_levels',NEW.id,'update',json_object('id',OLD.id,'title',OLD.title,'threshold',OLD.threshold,'cashback',OLD.cashback),json_object('id',NEW.id,'title',NEW.title,'threshold',NEW.threshold,'cashback',NEW.cashback));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_levels_delete AFTER DELETE ON bx_club_levels BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_levels',OLD.id,'delete',json_object('id',OLD.id,'title',OLD.title,'threshold',OLD.threshold,'cashback',OLD.cashback),NULL);
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_settings_insert AFTER INSERT ON bx_club_settings BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_settings',NEW.id,'insert',NULL,json_object('id',NEW.id,'redeem_percent',NEW.redeem_percent));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_settings_update AFTER UPDATE ON bx_club_settings WHEN OLD.id IS NOT NEW.id OR OLD.redeem_percent IS NOT NEW.redeem_percent BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_settings',NEW.id,'update',json_object('id',OLD.id,'redeem_percent',OLD.redeem_percent),json_object('id',NEW.id,'redeem_percent',NEW.redeem_percent));
END;

CREATE TRIGGER IF NOT EXISTS bx_audit_bx_club_settings_delete AFTER DELETE ON bx_club_settings BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('club','bx_club_settings',OLD.id,'delete',json_object('id',OLD.id,'redeem_percent',OLD.redeem_percent),NULL);
END;


-- FILE: 0021_cost_accounting.sql
-- RULES. после 0020. Себестоимость в целых рублях; NULL означает «неизвестно», не ноль.
CREATE TABLE IF NOT EXISTS bx_product_costs (
 product_id TEXT PRIMARY KEY REFERENCES products(id),
 unit_cost INTEGER CHECK(unit_cost IS NULL OR unit_cost BETWEEN 0 AND 10000000),
 updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_order_cost_lines (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 order_id TEXT NOT NULL REFERENCES orders(id),
 kind TEXT NOT NULL CHECK(kind IN ('sold','gift_product','gift_other')),
 source_key TEXT NOT NULL, name TEXT NOT NULL,
 qty INTEGER NOT NULL CHECK(qty>0),
 unit_cost INTEGER CHECK(unit_cost IS NULL OR unit_cost BETWEEN 0 AND 10000000),
 updated_at TEXT NOT NULL DEFAULT(datetime('now')),
 UNIQUE(order_id,kind,source_key)
);
CREATE INDEX IF NOT EXISTS bx_order_cost_order ON bx_order_cost_lines(order_id);
-- Для исторических заказов стоимость специально не угадывается по текущему каталогу.
INSERT OR IGNORE INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 SELECT order_id,'sold',CAST(id AS TEXT),name,qty,NULL FROM order_items;
INSERT OR IGNORE INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 SELECT order_id,'gift_product',product_id,product_name,qty,NULL FROM bx_order_gifts WHERE product_id!='';
INSERT OR IGNORE INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 SELECT order_id,'gift_other','description',description,1,NULL FROM bx_order_gifts WHERE description!='';
CREATE TRIGGER IF NOT EXISTS bx_cost_sold_snapshot AFTER INSERT ON order_items BEGIN
 INSERT INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 VALUES(NEW.order_id,'sold',CAST(NEW.id AS TEXT),NEW.name,NEW.qty,(SELECT unit_cost FROM bx_product_costs WHERE product_id=NEW.product_id));
END;
CREATE TRIGGER IF NOT EXISTS bx_cost_gift_snapshot AFTER INSERT ON bx_order_gifts BEGIN
 INSERT INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 SELECT NEW.order_id,'gift_product',NEW.product_id,NEW.product_name,NEW.qty,(SELECT unit_cost FROM bx_product_costs WHERE product_id=NEW.product_id) WHERE NEW.product_id!='';
 INSERT INTO bx_order_cost_lines(order_id,kind,source_key,name,qty,unit_cost)
 SELECT NEW.order_id,'gift_other','description',NEW.description,1,NULL WHERE NEW.description!='';
END;
CREATE TRIGGER IF NOT EXISTS bx_cost_catalog_insert AFTER INSERT ON bx_product_costs BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('cost','bx_product_costs',NEW.product_id,'insert',NULL,json_object('product_id',NEW.product_id,'unit_cost',NEW.unit_cost));
END;
CREATE TRIGGER IF NOT EXISTS bx_cost_catalog_update AFTER UPDATE OF unit_cost ON bx_product_costs WHEN OLD.unit_cost IS NOT NEW.unit_cost BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('cost','bx_product_costs',NEW.product_id,'update',json_object('product_id',OLD.product_id,'unit_cost',OLD.unit_cost),json_object('product_id',NEW.product_id,'unit_cost',NEW.unit_cost));
END;
CREATE TRIGGER IF NOT EXISTS bx_cost_order_update AFTER UPDATE OF unit_cost ON bx_order_cost_lines WHEN OLD.unit_cost IS NOT NEW.unit_cost BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('cost','bx_order_cost_lines',NEW.order_id||':'||NEW.id,'update',json_object('name',OLD.name,'qty',OLD.qty,'unit_cost',OLD.unit_cost),json_object('name',NEW.name,'qty',NEW.qty,'unit_cost',NEW.unit_cost));
END;


-- FILE: 0022_cashbook.sql
-- RULES. после 0021: ручной журнал денежных операций, не банковская интеграция.
CREATE TABLE IF NOT EXISTS bx_cashbook (
 id TEXT PRIMARY KEY,
 event_date TEXT NOT NULL,
 kind TEXT NOT NULL CHECK(kind IN ('sale_receipt','customer_refund','supplier_payment','delivery_cost','fees','taxes','marketing','rent','payroll','other_expense','other_receipt','owner_in','owner_out')),
 amount INTEGER NOT NULL CHECK(amount BETWEEN 1 AND 100000000),
 description TEXT NOT NULL DEFAULT '',order_id TEXT REFERENCES orders(id),
 voided INTEGER NOT NULL DEFAULT 0 CHECK(voided IN (0,1)),
 version TEXT NOT NULL,created_at TEXT NOT NULL DEFAULT(datetime('now')),updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_cashbook_date ON bx_cashbook(event_date,id);
CREATE TRIGGER IF NOT EXISTS bx_cashbook_audit_insert AFTER INSERT ON bx_cashbook BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('finance','bx_cashbook',NEW.id,'insert',NULL,json_object('event_date',NEW.event_date,'kind',NEW.kind,'amount',NEW.amount,'description',NEW.description,'order_id',NEW.order_id,'voided',NEW.voided));
END;
CREATE TRIGGER IF NOT EXISTS bx_cashbook_audit_update AFTER UPDATE ON bx_cashbook
WHEN OLD.event_date IS NOT NEW.event_date OR OLD.kind IS NOT NEW.kind OR OLD.amount IS NOT NEW.amount OR OLD.description IS NOT NEW.description OR OLD.order_id IS NOT NEW.order_id OR OLD.voided IS NOT NEW.voided BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('finance','bx_cashbook',NEW.id,'update',json_object('event_date',OLD.event_date,'kind',OLD.kind,'amount',OLD.amount,'description',OLD.description,'order_id',OLD.order_id,'voided',OLD.voided),json_object('event_date',NEW.event_date,'kind',NEW.kind,'amount',NEW.amount,'description',NEW.description,'order_id',NEW.order_id,'voided',NEW.voided));
END;


-- FILE: 0023_promo_extra_conditions.sql
-- RULES. после 0022. Лимиты считают все сохранённые заказы, включая отменённые.
CREATE TABLE IF NOT EXISTS bx_promo_extra (
 code TEXT PRIMARY KEY REFERENCES bx_promos(code),
 require_login INTEGER NOT NULL DEFAULT 0 CHECK(require_login IN (0,1)),
 first_linked_order INTEGER NOT NULL DEFAULT 0 CHECK(first_linked_order IN (0,1)),
 max_per_customer INTEGER NOT NULL DEFAULT 0 CHECK(max_per_customer BETWEEN 0 AND 10000000),
 required_product TEXT NOT NULL DEFAULT '',
 min_quantity INTEGER NOT NULL DEFAULT 0 CHECK(min_quantity BETWEEN 0 AND 20),
 CHECK((required_product='' AND min_quantity=0) OR (required_product!='' AND min_quantity BETWEEN 1 AND 20))
);
CREATE INDEX IF NOT EXISTS bx_finance_promo_customer ON bx_order_finance(promo_code,customer_id);
CREATE TRIGGER IF NOT EXISTS bx_promo_extra_guard BEFORE INSERT ON bx_order_finance
WHEN NEW.promo_code!='' BEGIN
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_promo_extra x WHERE x.code=NEW.promo_code
  AND (x.require_login=1 OR x.first_linked_order=1 OR x.max_per_customer>0)
  AND (NEW.customer_id IS NULL OR NOT EXISTS(SELECT 1 FROM bx_order_owners ow WHERE ow.order_id=NEW.order_id AND ow.customer_id=NEW.customer_id)))
 THEN RAISE(ABORT,'promo_login_required') END;
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_promo_extra x WHERE x.code=NEW.promo_code AND x.first_linked_order=1
  AND EXISTS(SELECT 1 FROM bx_order_owners ow WHERE ow.customer_id=NEW.customer_id AND ow.order_id!=NEW.order_id))
 THEN RAISE(ABORT,'promo_first_linked_order_only') END;
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_promo_extra x WHERE x.code=NEW.promo_code AND x.max_per_customer>0
  AND (SELECT COUNT(*) FROM bx_order_finance f WHERE f.promo_code=NEW.promo_code AND f.customer_id=NEW.customer_id)>=x.max_per_customer)
 THEN RAISE(ABORT,'promo_customer_limit') END;
 SELECT CASE WHEN EXISTS(SELECT 1 FROM bx_promo_extra x WHERE x.code=NEW.promo_code AND x.required_product!=''
  AND COALESCE((SELECT SUM(i.qty) FROM order_items i WHERE i.order_id=NEW.order_id AND i.product_id=x.required_product),0)<x.min_quantity)
 THEN RAISE(ABORT,'promo_required_product') END;
END;
CREATE TRIGGER IF NOT EXISTS bx_extra_audit_insert AFTER INSERT ON bx_promo_extra BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_extra',NEW.code,'insert',NULL,json_object('require_login',NEW.require_login,'first_linked_order',NEW.first_linked_order,'max_per_customer',NEW.max_per_customer,'required_product',NEW.required_product,'min_quantity',NEW.min_quantity));
END;
CREATE TRIGGER IF NOT EXISTS bx_extra_audit_update AFTER UPDATE ON bx_promo_extra WHEN OLD.require_login IS NOT NEW.require_login OR OLD.first_linked_order IS NOT NEW.first_linked_order OR OLD.max_per_customer IS NOT NEW.max_per_customer OR OLD.required_product IS NOT NEW.required_product OR OLD.min_quantity IS NOT NEW.min_quantity BEGIN
 INSERT INTO bx_config_audit(module,entity,entity_key,action,old_json,new_json) VALUES('promo','bx_promo_extra',NEW.code,'update',json_object('require_login',OLD.require_login,'first_linked_order',OLD.first_linked_order,'max_per_customer',OLD.max_per_customer,'required_product',OLD.required_product,'min_quantity',OLD.min_quantity),json_object('require_login',NEW.require_login,'first_linked_order',NEW.first_linked_order,'max_per_customer',NEW.max_per_customer,'required_product',NEW.required_product,'min_quantity',NEW.min_quantity));
END;


-- FILE: 0024_login_code.sql
-- RULES.: ограничение попыток ввода одноразового кода. Никакие существующие данные не удаляются.
CREATE TABLE IF NOT EXISTS bx_login_code_attempts (
 id TEXT PRIMARY KEY,
 ip_hash TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS bx_login_code_attempts_ip_time ON bx_login_code_attempts(ip_hash,created_at);
CREATE TRIGGER IF NOT EXISTS bx_login_code_rate_guard BEFORE INSERT ON bx_login_code_attempts
WHEN (SELECT COUNT(*) FROM bx_login_code_attempts WHERE ip_hash=NEW.ip_hash AND created_at>datetime('now','-15 minutes'))>=15
BEGIN SELECT RAISE(ABORT,'login_rate_limited'); END;


-- FILE: 0025_product_details.sql
-- RULES.: расширенная информация для страниц товаров. Действующие товары и остатки сохраняются.
CREATE TABLE IF NOT EXISTS bx_product_details (
 product_id TEXT PRIMARY KEY REFERENCES products(id),
 long_description TEXT NOT NULL DEFAULT '' CHECK(length(long_description)<=3000),
 composition TEXT NOT NULL DEFAULT '' CHECK(length(composition)<=3000),
 directions TEXT NOT NULL DEFAULT '' CHECK(length(directions)<=3000),
 nutrition TEXT NOT NULL DEFAULT '' CHECK(length(nutrition)<=3000),
 warnings TEXT NOT NULL DEFAULT '' CHECK(length(warnings)<=3000),
 size_text TEXT NOT NULL DEFAULT '' CHECK(length(size_text)<=200),
 updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0026_product_images.sql
-- RULES.: изображения товаров в D1. Существующие ссылки на файлы assets остаются без изменений.
CREATE TABLE IF NOT EXISTS bx_media_assets (
 hash TEXT PRIMARY KEY CHECK(length(hash)=64),
 mime TEXT NOT NULL CHECK(mime IN ('image/webp','image/jpeg')),
 data_base64 TEXT NOT NULL CHECK(length(data_base64)<=600000),
 created_at TEXT NOT NULL DEFAULT(datetime('now'))
);
CREATE TABLE IF NOT EXISTS bx_product_images (
 product_id TEXT PRIMARY KEY REFERENCES products(id),
 catalog_hash TEXT REFERENCES bx_media_assets(hash),
 page_hash TEXT REFERENCES bx_media_assets(hash),
 updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0027_delivery_quotes.sql
-- Draft only for a NEW RULES. database. Quotation is provisional, not a payment or final delivery charge.
CREATE TABLE IF NOT EXISTS rules_delivery_quotes (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 method TEXT NOT NULL CHECK(method IN ('pickup','courier','cdek')),
 state TEXT NOT NULL CHECK(state IN ('pickup','to_be_confirmed','zone_to_be_confirmed','estimated','estimated_free','free_by_promo')),
 quoted_rub INTEGER CHECK(quoted_rub IS NULL OR quoted_rub>=0),
 merchandise_after_discounts INTEGER NOT NULL CHECK(merchandise_after_discounts>=0),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);


-- FILE: 0028_delivery_settings.sql
-- Only for a new RULES. test database; values in whole rubles.
CREATE TABLE IF NOT EXISTS rules_delivery_settings (
 id INTEGER PRIMARY KEY CHECK(id=1),
 courier_price INTEGER NOT NULL CHECK(courier_price BETWEEN 0 AND 1000000),
 free_from INTEGER NOT NULL CHECK(free_from BETWEEN 0 AND 100000000),
 updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);
INSERT OR IGNORE INTO rules_delivery_settings(id,courier_price,free_from) VALUES(1,790,5000);
CREATE TABLE IF NOT EXISTS rules_delivery_settings_audit (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 old_courier_price INTEGER NOT NULL, old_free_from INTEGER NOT NULL,
 new_courier_price INTEGER NOT NULL, new_free_from INTEGER NOT NULL,
 changed_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0029_order_contacts_zone.sql
-- New RULES database only. Buyer-provided zone is a request, not verified service coverage.
CREATE TABLE IF NOT EXISTS rules_order_contact_delivery (
 order_id TEXT PRIMARY KEY REFERENCES orders(id) ON DELETE CASCADE,
 email TEXT NOT NULL DEFAULT '' CHECK(length(email)<=254),
 requested_zone TEXT CHECK(requested_zone IN ('moscow','oblast') OR requested_zone IS NULL)
);


-- FILE: 0030_confirmed_delivery.sql
-- Draft, new RULES DB only. A buyer-selected zone is not a confirmation.
CREATE TABLE IF NOT EXISTS rules_oblast_delivery_settings (
 id INTEGER PRIMARY KEY CHECK(id=1), courier_price INTEGER NOT NULL CHECK(courier_price BETWEEN 0 AND 1000000), updated_at TEXT NOT NULL DEFAULT(datetime('now'))
);
INSERT OR IGNORE INTO rules_oblast_delivery_settings(id,courier_price) VALUES(1,1200);
CREATE TABLE IF NOT EXISTS rules_confirmed_delivery (
 order_id TEXT PRIMARY KEY REFERENCES orders(id),
 zone TEXT NOT NULL CHECK(zone IN ('moscow','oblast')),
 amount INTEGER NOT NULL CHECK(amount>=0),
 basis_goods INTEGER NOT NULL CHECK(basis_goods>=0),
 confirmed_at TEXT NOT NULL DEFAULT(datetime('now'))
);
CREATE TABLE IF NOT EXISTS rules_confirmed_delivery_history (
 id INTEGER PRIMARY KEY AUTOINCREMENT,order_id TEXT NOT NULL REFERENCES orders(id),
 zone TEXT NOT NULL CHECK(zone IN ('moscow','oblast')),amount INTEGER NOT NULL CHECK(amount>=0),
 basis_goods INTEGER NOT NULL CHECK(basis_goods>=0),confirmed_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0031_guest_invoice_access.sql
-- New RULES database only; no plaintext access keys in the database.
CREATE TABLE IF NOT EXISTS rules_guest_invoice_access (
 order_id TEXT PRIMARY KEY REFERENCES orders(id) ON DELETE CASCADE,
 token_hash TEXT NOT NULL CHECK(length(token_hash)=64),
 expires_at TEXT NOT NULL,
 created_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0032_oblast_tariff_audit.sql
-- Draft migration for the new RULES database only.
CREATE TABLE IF NOT EXISTS rules_oblast_delivery_settings_audit (
 id INTEGER PRIMARY KEY AUTOINCREMENT,old_price INTEGER NOT NULL,new_price INTEGER NOT NULL,
 changed_at TEXT NOT NULL DEFAULT(datetime('now'))
);


-- FILE: 0033_invoice_versions.sql
-- Draft for new RULES D1 only. Retain historical data; revocation cannot erase downloaded PDFs.
CREATE TABLE IF NOT EXISTS rules_invoice_versions (
 version_id TEXT PRIMARY KEY,
 order_id TEXT NOT NULL REFERENCES orders(id),
 snapshot_json TEXT NOT NULL,
 issued_at TEXT NOT NULL DEFAULT(datetime('now')),
 revoked_at TEXT,
 revoke_reason TEXT NOT NULL DEFAULT ''
);
CREATE UNIQUE INDEX IF NOT EXISTS rules_invoice_one_active ON rules_invoice_versions(order_id) WHERE revoked_at IS NULL;
CREATE TRIGGER IF NOT EXISTS rules_invoice_cancelled AFTER UPDATE OF status ON orders
WHEN NEW.status='cancelled' AND OLD.status<>'cancelled' BEGIN
 UPDATE rules_invoice_versions SET revoked_at=datetime('now'),revoke_reason='Заказ отменён' WHERE order_id=NEW.id AND revoked_at IS NULL;
 DELETE FROM rules_confirmed_delivery WHERE order_id=NEW.id;
END;


-- FILE: 0034_initial_product_details.sql
-- RULES. / карточки стартового ассортимента. Ароматические образы — не составы.
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-01','Ароматический образ: верх — сухая можжевеловая свежесть, чёрный перец; сердце — кедрово-древесный аккорд, шалфей; база — ветиверовый, амброво-древесный и мягкий кожаный акценты. Локальная отсылка — можжевеловые горные ландшафты; источник ингредиентов не заявляется. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-02','Ароматический образ: верх — зелёный мандариновый аккорд, ароматические травы; сердце — горный чабрец как ароматический образ, шалфей, прозрачная хвоя; база — сухая древесина и чистый мускусный аккорд. Отсылка — высокогорные травы и солнечные склоны. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-03','Ароматический образ: верх — чёрный перец и сухой фруктовый акцент; сердце — кожа, чёрный чай; база — кедровая древесина, смола, тёмная амбра. Отсылка — гостеприимство, чай и фактура ремесленных материалов, без утверждения об исторической аутентичности. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-04','Ароматический образ: верх — прохладный зелёный аккорд, бергамотовое впечатление; сердце — хвоя, травы; база — светлая древесина и минеральный мускус. Отсылка — открытый горный горизонт. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-05','Ароматический образ: верх — грецкий орех как сухой древесно-ореховый аккорд, кориандр; сердце — инжирная древесина, лист табака как парфюмерный образ; база — мягкая амбра и кедр. Отсылка — сады и ореховые древесные образы региона. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-06','Ароматический образ: верх — гранатовая кислинка, чёрный перец; сердце — чёрный чай, мягкая кожа; база — амброво-древесный аккорд, смолы и сухой кедр. Гранат — узнаваемый плодовый образ региона; кожаный и гранатовый аккорды не равны реальному сырью. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-07','Ароматический образ: верх — прохладный воздух, прозрачная зелень; сердце — горные травы, чабрец; база — минеральный камень, светлая древесина. Здесь нет утверждения, что аромат воспроизводит реальный запах воды озера. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-08','Ароматический образ: верх — прозрачный цитрусово-зелёный аккорд; сердце — шалфей, горные травы; база — сухой камень, ветивер и светлое дерево. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-09','Ароматический образ: верх — гранатовая терпкость, лист инжира; сердце — чёрный чай и сухие травы; база — нагретый камень как минеральный аккорд, кедр, смолистое тепло. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-10','Ароматический образ: верх — сухой воздух и шалфей; сердце — камень, можжевельник; база — древесина, мягкий дымчатый и смолистый акценты. Это современная художественная интерпретация, не утверждение об историческом запахе места. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-11','Ароматический образ: верх — гранатовая кислинка и розовый перец; сердце — мягкая кожа, чёрный чай; база — сухой кедр и тёплая амбра. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-12','Ароматический образ: верх — свежий инжирный лист; сердце — зелёный инжир и чёрный чай; база — кедр, мягкий древесный дым, амбра. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-13','Ароматический образ: верх — чабрец и зелёная прохлада; сердце — шалфей и минеральный аккорд; база — светлая древесина и чистый мускус. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-14','Ароматический образ: верх — зелёная ореховая шелуха; сердце — сухая древесина и чай; база — каменный минеральный аккорд, ветивер и мягкая амбра. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
INSERT INTO bx_product_details(product_id,long_description,composition,directions) VALUES('rules-15','Ароматический образ: верх — яркий терпкий облепиховый аккорд, цитрусовая цедра; сердце — сухие травы и чай; база — кедр и мягкая древесная амбра. Ароматическая концепция; фактический состав и характеристики уточняйте по маркировке товара.','Состав и характеристики уточняйте по маркировке товара или у продавца.','Перед применением ознакомьтесь с инструкцией и предупреждениями на упаковке.');
