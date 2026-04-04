package csd230.bookstore.controllers;

import csd230.bookstore.entities.DrumKitEntity;
import csd230.bookstore.repositories.DrumKitEntityRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/drums")
@CrossOrigin(origins = "*")
public class DrumKitRestController {

    private final DrumKitEntityRepository drumKitRepository;

    public DrumKitRestController(DrumKitEntityRepository drumKitRepository) {
        this.drumKitRepository = drumKitRepository;
    }

    @GetMapping
    public List<DrumKitEntity> all() {
        return drumKitRepository.findAll();
    }

    @GetMapping("/{id}")
    public DrumKitEntity getOne(@PathVariable Long id) {
        return drumKitRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public DrumKitEntity create(@RequestBody DrumKitEntity newDrumKit) {
        return drumKitRepository.save(newDrumKit);
    }

    @PutMapping("/{id}")
    public DrumKitEntity update(@RequestBody DrumKitEntity updatedDrumKit, @PathVariable Long id) {
        return drumKitRepository.findById(id)
                .map(drumKit -> {
                    drumKit.setBrand(updatedDrumKit.getBrand());
                    drumKit.setPieces(updatedDrumKit.getPieces());
                    drumKit.setPrice(updatedDrumKit.getPrice());
                    return drumKitRepository.save(drumKit);
                })
                .orElseGet(() -> {
                    updatedDrumKit.setId(id);
                    return drumKitRepository.save(updatedDrumKit);
                });
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        drumKitRepository.deleteById(id);
    }
}