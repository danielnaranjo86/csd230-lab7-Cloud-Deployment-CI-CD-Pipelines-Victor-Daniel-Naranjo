package csd230.bookstore.controllers;

import csd230.bookstore.entities.GuitarEntity;
import csd230.bookstore.repositories.GuitarEntityRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rest/guitars")
@CrossOrigin(origins = "*")
public class GuitarRestController {

    private final GuitarEntityRepository guitarRepository;

    public GuitarRestController(GuitarEntityRepository guitarRepository) {
        this.guitarRepository = guitarRepository;
    }

    @GetMapping
    public List<GuitarEntity> all() {
        return guitarRepository.findAll();
    }

    @GetMapping("/{id}")
    public GuitarEntity getOne(@PathVariable Long id) {
        return guitarRepository.findById(id).orElseThrow();
    }

    @PostMapping
    public GuitarEntity create(@RequestBody GuitarEntity newGuitar) {
        return guitarRepository.save(newGuitar);
    }

    @PutMapping("/{id}")
    public GuitarEntity update(@RequestBody GuitarEntity updatedGuitar, @PathVariable Long id) {
        return guitarRepository.findById(id)
                .map(guitar -> {
                    guitar.setBrand(updatedGuitar.getBrand());
                    guitar.setModel(updatedGuitar.getModel());
                    guitar.setPrice(updatedGuitar.getPrice());
                    return guitarRepository.save(guitar);
                })
                .orElseGet(() -> {
                    updatedGuitar.setId(id);
                    return guitarRepository.save(updatedGuitar);
                });
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        guitarRepository.deleteById(id);
    }
}