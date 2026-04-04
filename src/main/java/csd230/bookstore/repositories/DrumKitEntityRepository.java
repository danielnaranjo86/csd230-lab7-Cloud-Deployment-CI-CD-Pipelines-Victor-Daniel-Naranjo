package csd230.bookstore.repositories;

import csd230.bookstore.entities.DrumKitEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DrumKitEntityRepository extends JpaRepository<DrumKitEntity, Long> {
}