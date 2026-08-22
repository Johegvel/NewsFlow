-- ==============================================================================
-- FLEWS (NEWSFLOW) - ESQUEMA DE BASE DE DATOS PARA SUPABASE POSTGRESQL
-- ==============================================================================

-- 1. Habilitar extensiones
CREATE EXTENSION IF NOT EXISTS "plpgsql";

-- 2. Tabla: Users
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    password_digest VARCHAR,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 3. Tabla: Communities
CREATE TABLE IF NOT EXISTS communities (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    slug VARCHAR NOT NULL UNIQUE,
    description TEXT,
    topic VARCHAR,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 4. Tabla: Interests
CREATE TABLE IF NOT EXISTS interests (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    slug VARCHAR NOT NULL UNIQUE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 5. Tabla: User Interests (Relación Muchos a Muchos)
CREATE TABLE IF NOT EXISTS user_interests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interest_id BIGINT NOT NULL REFERENCES interests(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT index_user_interests_on_user_id_and_interest_id UNIQUE (user_id, interest_id)
);

-- 6. Tabla: Posts (Noticias y Críticas)
CREATE TABLE IF NOT EXISTS posts (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    content TEXT NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    community_id BIGINT NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    post_type INTEGER DEFAULT 0,
    status INTEGER DEFAULT 0,
    published_at TIMESTAMP WITHOUT TIME ZONE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 7. Tabla: Comments
CREATE TABLE IF NOT EXISTS comments (
    id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 8. Tabla: Reactions
CREATE TABLE IF NOT EXISTS reactions (
    id BIGSERIAL PRIMARY KEY,
    kind INTEGER NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT index_reactions_on_user_and_post UNIQUE (user_id, post_id)
);

-- 9. Tabla: Reports
CREATE TABLE IF NOT EXISTS reports (
    id BIGSERIAL PRIMARY KEY,
    reason TEXT NOT NULL,
    status INTEGER DEFAULT 0,
    reviewed_at TIMESTAMP WITHOUT TIME ZONE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

-- 10. Tabla: Saved Posts (Marcadores / Guardados)
CREATE TABLE IF NOT EXISTS saved_posts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT index_saved_posts_on_user_and_post UNIQUE (user_id, post_id)
);

-- 11. Índices de Rendimiento
CREATE INDEX IF NOT EXISTS index_comments_on_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS index_comments_on_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS index_posts_on_community_id ON posts(community_id);
CREATE INDEX IF NOT EXISTS index_posts_on_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS index_reactions_on_post_id ON reactions(post_id);
CREATE INDEX IF NOT EXISTS index_reactions_on_user_id ON reactions(user_id);
CREATE INDEX IF NOT EXISTS index_reports_on_post_id ON reports(post_id);
CREATE INDEX IF NOT EXISTS index_reports_on_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS index_saved_posts_on_post_id ON saved_posts(post_id);
CREATE INDEX IF NOT EXISTS index_saved_posts_on_user_id ON saved_posts(user_id);
CREATE INDEX IF NOT EXISTS index_user_interests_on_interest_id ON user_interests(interest_id);
CREATE INDEX IF NOT EXISTS index_user_interests_on_user_id ON user_interests(user_id);

-- 12. Semillas Iniciales (Datos base)
INSERT INTO users (name, email, password_digest, created_at, updated_at)
VALUES 
  ('Johan Veloz', 'johan@newsflow.com', '$2a$12$e0M2l1fV44kP9K9K9K9K9e9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9', NOW(), NOW()),
  ('Xavier Camacho', 'xavier@newsflow.com', '$2a$12$e0M2l1fV44kP9K9K9K9K9e9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9', NOW(), NOW()),
  ('Manuel Matute', 'manuel@newsflow.com', '$2a$12$e0M2l1fV44kP9K9K9K9K9e9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9', NOW(), NOW()),
  ('Flews Curador', 'bot@flews.app', '$2a$12$e0M2l1fV44kP9K9K9K9K9e9K9K9K9K9K9K9K9K9K9K9K9K9K9K9K9', NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

INSERT INTO communities (name, slug, description, topic, created_at, updated_at)
VALUES
  ('Tecnología', 'tecnologia', 'Noticias de última hora sobre software, hardware e inteligencia artificial.', 'Tecnología', NOW(), NOW()),
  ('Ciencia', 'ciencia', 'Descubrimientos, avances científicos y exploración espacial.', 'Ciencia', NOW(), NOW()),
  ('Salud', 'salud', 'Investigación médica, bienestar, longevidad y avances en biotecnología.', 'Salud', NOW(), NOW()),
  ('Gastronomía', 'gastronomia', 'Tendencias culinarias, ciencia de los alimentos y alta cocina global.', 'Gastronomía', NOW(), NOW()),
  ('Deportes', 'deportes', 'Actualidad, análisis y resultados de las principales disciplinas deportivas.', 'Deportes', NOW(), NOW()),
  ('Ciberseguridad', 'ciberseguridad', 'Vulnerabilidades críticas, análisis de amenazas e ingeniería de seguridad.', 'Ciberseguridad', NOW(), NOW()),
  ('Negocios', 'negocios', 'Startups, finanzas, mercados globales y venture capital.', 'Negocios', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO interests (name, slug, created_at, updated_at)
VALUES
  ('Tecnología & IA', 'tecnologia', NOW(), NOW()),
  ('Deportes', 'deportes', NOW(), NOW()),
  ('Ciencia & Espacio', 'ciencia', NOW(), NOW()),
  ('Salud & Medicina', 'salud', NOW(), NOW()),
  ('Gastronomía', 'gastronomia', NOW(), NOW()),
  ('Ciberseguridad', 'ciberseguridad', NOW(), NOW()),
  ('Negocios & Startups', 'negocios', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;
