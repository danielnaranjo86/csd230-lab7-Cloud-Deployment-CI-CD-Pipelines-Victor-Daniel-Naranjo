package csd230.bookstore.repositories;

import csd230.bookstore.entities.GuitarEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GuitarEntityRepository extends JpaRepository<GuitarEntity, Long> {
}