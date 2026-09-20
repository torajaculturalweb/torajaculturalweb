-- Toraja Pusaka - jalankan seluruh file ini di Supabase SQL Editor.
create extension if not exists "pgcrypto";

create type public.content_status as enum ('draft','published','archived');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'admin' check (role in ('admin','editor')),
  created_at timestamptz not null default now()
);
create table public.cultural_contents (
  id uuid primary key default gen_random_uuid(), slug text unique not null,
  category text not null, title text not null, summary text, body text,
  image_url text, status content_status not null default 'draft',
  created_by uuid references public.profiles(id), created_at timestamptz default now(), updated_at timestamptz default now()
);
create table public.destinations (
  id uuid primary key default gen_random_uuid(), slug text unique not null,
  name text not null, category text, summary text, address text,
  latitude numeric, longitude numeric, ticket_price text, opening_hours text,
  image_url text, status content_status not null default 'draft',
  created_by uuid references public.profiles(id), created_at timestamptz default now(), updated_at timestamptz default now()
);
create table public.articles (
  id uuid primary key default gen_random_uuid(), slug text unique not null,
  title text not null, category text, excerpt text, content text, author text,
  published_at date default current_date, cover_url text,
  status content_status not null default 'draft', created_by uuid references public.profiles(id),
  created_at timestamptz default now(), updated_at timestamptz default now()
);
create table public.cultural_events (
  id uuid primary key default gen_random_uuid(), title text not null,
  description text, location text, start_date date not null, end_date date,
  image_url text, status content_status not null default 'draft',
  created_by uuid references public.profiles(id), created_at timestamptz default now(), updated_at timestamptz default now()
);
create table public.galleries (
  id uuid primary key default gen_random_uuid(), title text not null, description text,
  cover_url text, status content_status not null default 'draft', created_at timestamptz default now()
);
create table public.gallery_items (
  id uuid primary key default gen_random_uuid(), gallery_id uuid references public.galleries(id) on delete cascade,
  image_url text not null, caption text, credit text, sort_order integer default 0, created_at timestamptz default now()
);
create table public.videos (
  id uuid primary key default gen_random_uuid(), title text not null, description text,
  youtube_url text not null, thumbnail_url text, category text,
  status content_status not null default 'draft', created_at timestamptz default now()
);
create table public.quiz_categories (
  id uuid primary key default gen_random_uuid(), name text not null, description text, status content_status default 'published'
);
create table public.quiz_questions (
  id uuid primary key default gen_random_uuid(), category_id uuid references public.quiz_categories(id) on delete cascade,
  question text not null, options jsonb not null check (jsonb_array_length(options)=4),
  correct_answer integer not null check (correct_answer between 0 and 3), explanation text,
  difficulty text default 'mudah', status content_status default 'published', created_at timestamptz default now()
);
create table public.quiz_attempts (
  id uuid primary key default gen_random_uuid(), category_id uuid references public.quiz_categories(id) on delete set null,
  score numeric not null, total_questions integer not null, created_at timestamptz default now()
);
create table public.sus_responses (
  id uuid primary key default gen_random_uuid(), respondent_group text not null,
  responses integer[] not null check (array_length(responses,1)=10),
  score numeric not null check (score between 0 and 100), comments text,
  user_agent text, created_at timestamptz default now()
);
create table public.contact_messages (
  id uuid primary key default gen_random_uuid(), name text not null, email text not null,
  subject text not null, message text not null, is_read boolean default false, created_at timestamptz default now()
);
create table public.site_settings (
  key text primary key, value jsonb not null, updated_at timestamptz default now()
);

create or replace function public.is_staff() returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.profiles where id=auth.uid() and role in ('admin','editor'));
$$;
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,full_name,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name',new.email),'admin') on conflict do nothing; return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
create trigger cultural_updated before update on public.cultural_contents for each row execute procedure public.set_updated_at();
create trigger destination_updated before update on public.destinations for each row execute procedure public.set_updated_at();
create trigger article_updated before update on public.articles for each row execute procedure public.set_updated_at();
create trigger event_updated before update on public.cultural_events for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.cultural_contents enable row level security;
alter table public.destinations enable row level security;
alter table public.articles enable row level security;
alter table public.cultural_events enable row level security;
alter table public.galleries enable row level security;
alter table public.gallery_items enable row level security;
alter table public.videos enable row level security;
alter table public.quiz_categories enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.sus_responses enable row level security;
alter table public.contact_messages enable row level security;
alter table public.site_settings enable row level security;

create policy "own profile" on public.profiles for select using(id=auth.uid() or public.is_staff());
create policy "public published culture" on public.cultural_contents for select using(status='published' or public.is_staff());
create policy "staff culture" on public.cultural_contents for all using(public.is_staff()) with check(public.is_staff());
create policy "public published destinations" on public.destinations for select using(status='published' or public.is_staff());
create policy "staff destinations" on public.destinations for all using(public.is_staff()) with check(public.is_staff());
create policy "public published articles" on public.articles for select using(status='published' or public.is_staff());
create policy "staff articles" on public.articles for all using(public.is_staff()) with check(public.is_staff());
create policy "public published events" on public.cultural_events for select using(status='published' or public.is_staff());
create policy "staff events" on public.cultural_events for all using(public.is_staff()) with check(public.is_staff());
create policy "public galleries" on public.galleries for select using(status='published' or public.is_staff());
create policy "staff galleries" on public.galleries for all using(public.is_staff()) with check(public.is_staff());
create policy "public gallery items" on public.gallery_items for select using(true);
create policy "staff gallery items" on public.gallery_items for all using(public.is_staff()) with check(public.is_staff());
create policy "public videos" on public.videos for select using(status='published' or public.is_staff());
create policy "staff videos" on public.videos for all using(public.is_staff()) with check(public.is_staff());
create policy "public quiz categories" on public.quiz_categories for select using(status='published' or public.is_staff());
create policy "staff quiz categories" on public.quiz_categories for all using(public.is_staff()) with check(public.is_staff());
create policy "public quiz questions" on public.quiz_questions for select using(status='published' or public.is_staff());
create policy "staff quiz questions" on public.quiz_questions for all using(public.is_staff()) with check(public.is_staff());
create policy "submit quiz attempts" on public.quiz_attempts for insert with check(true);
create policy "staff quiz attempts" on public.quiz_attempts for select using(public.is_staff());
create policy "submit sus" on public.sus_responses for insert with check(score between 0 and 100);
create policy "staff sus" on public.sus_responses for select using(public.is_staff());
create policy "submit contact" on public.contact_messages for insert with check(length(message) between 1 and 5000);
create policy "staff contact" on public.contact_messages for all using(public.is_staff()) with check(public.is_staff());
create policy "public settings" on public.site_settings for select using(true);
create policy "staff settings" on public.site_settings for all using(public.is_staff()) with check(public.is_staff());

insert into public.cultural_contents(slug,category,title,summary,body,image_url,status) values
('tongkonan','Rumah Adat','Tongkonan','Rumah adat leluhur dan pusat kehidupan sosial masyarakat Toraja.','Tongkonan bukan sekadar rumah tinggal. Bangunan ini menjadi pusat kekerabatan, musyawarah, dan identitas keluarga.','https://images.unsplash.com/photo-1604999333679-b86d54738315?auto=format&fit=crop&w=1400&q=80','published'),
('rambu-solo','Upacara Adat','Rambu Solo''','Upacara penghormatan terakhir yang merefleksikan ikatan keluarga dan masyarakat.','Rambu Solo'' merupakan rangkaian upacara kematian yang berkaitan dengan kepercayaan, gotong royong, dan penghormatan leluhur.','https://images.unsplash.com/photo-1596402184320-417e7178b2cd?auto=format&fit=crop&w=1400&q=80','published'),
('pa-tedong','Ukiran','Pa'' Tedong','Motif kerbau yang melambangkan kemakmuran, kekuatan, dan kedudukan.','Motif ini mengambil bentuk kepala kerbau yang memegang peranan penting dalam kehidupan sosial Toraja.','https://images.unsplash.com/photo-1577702312706-e23ff063064f?auto=format&fit=crop&w=1400&q=80','published');
insert into public.destinations(slug,name,category,summary,address,latitude,longitude,ticket_price,opening_hours,image_url,status) values
('kete-kesu','Ke''te'' Kesu''','Desa Adat','Desa adat dengan deretan Tongkonan, lumbung, dan situs pemakaman tradisional.','Kesu, Kabupaten Toraja Utara',-2.9962,119.9107,'Rp15.000','08.00-17.00 WITA','https://images.unsplash.com/photo-1558005530-a7958896ec60?auto=format&fit=crop&w=1400&q=80','published'),
('londa','Londa','Situs Budaya','Kompleks pemakaman batu yang memperlihatkan tradisi pemakaman masyarakat Toraja.','Sanggalangi, Kabupaten Toraja Utara',-3.0187,119.8673,'Rp15.000','08.00-17.00 WITA','https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=1400&q=80','published');
insert into public.articles(slug,title,category,excerpt,content,author,published_at,cover_url,status) values
('makna-warna-toraja','Membaca Makna Warna dalam Ukiran Toraja','Edukasi','Empat warna utama menyimpan filosofi kehidupan.','Merah, kuning, putih, dan hitam adalah warna utama pada ukiran Toraja dan memiliki makna simbolis.','Tim Toraja Pusaka',current_date,'https://images.unsplash.com/photo-1577702312706-e23ff063064f?auto=format&fit=crop&w=1400&q=80','published');
insert into public.cultural_events(title,description,location,start_date,end_date,image_url,status) values
('Festival Budaya Toraja','Pertunjukan seni, pameran kerajinan, dan kuliner tradisional.','Rantepao','2026-12-20','2026-12-23','https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1400&q=80','published');

-- Storage publik untuk unggahan media (opsional; UI saat ini juga menerima URL gambar).
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('media','media',true,5242880,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "public media read" on storage.objects for select using(bucket_id='media');
create policy "staff media insert" on storage.objects for insert with check(bucket_id='media' and public.is_staff());
create policy "staff media update" on storage.objects for update using(bucket_id='media' and public.is_staff());
create policy "staff media delete" on storage.objects for delete using(bucket_id='media' and public.is_staff());
