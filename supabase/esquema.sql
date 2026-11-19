create table mascotas (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users on delete cascade,
  nombre text not null,
  especie text not null,
  raza text not null default '',
  fecha_nacimiento date,
  sexo text not null default '',
  peso_kg numeric,
  foto_path text
);

create table tipos_cuidado (
  id bigint generated always as identity primary key,
  nombre text not null unique
);

create table cuidados (
  id bigint generated always as identity primary key,
  usuario_id uuid not null default auth.uid() references auth.users on delete cascade,
  mascota_id bigint not null references mascotas on delete cascade,
  tipo_cuidado_id bigint not null references tipos_cuidado,
  fecha date not null,
  notas text
);

insert into tipos_cuidado (nombre) values
  ('Vacunación'), ('Baño'), ('Desparasitación'), ('Visita veterinaria');

-- Reglas de acceso: cada usuario solo toca lo suyo.
alter table mascotas enable row level security;
alter table tipos_cuidado enable row level security;
alter table cuidados enable row level security;

create policy "mascotas propias" on mascotas for all to authenticated
  using (usuario_id = auth.uid()) with check (usuario_id = auth.uid());

-- El "with check" también exige que la mascota sea del usuario: la llave
-- foránea por sí sola no lo impide, porque no pasa por RLS.
create policy "cuidados propios" on cuidados for all to authenticated
  using (usuario_id = auth.uid())
  with check (
    usuario_id = auth.uid()
    and exists (
      select 1 from mascotas m
      where m.id = mascota_id and m.usuario_id = auth.uid()
    )
  );

create policy "catalogo de solo lectura" on tipos_cuidado for select to authenticated
  using (true);

-- Fotos: bucket privado, una carpeta por usuario.
insert into storage.buckets (id, name, public) values ('fotos-mascotas', 'fotos-mascotas', false);

create policy "fotos propias" on storage.objects for all to authenticated
  using (bucket_id = 'fotos-mascotas' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'fotos-mascotas' and (storage.foldername(name))[1] = auth.uid()::text);
