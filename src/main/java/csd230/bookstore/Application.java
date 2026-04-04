package csd230.bookstore;


import com.github.javafaker.Commerce;
import com.github.javafaker.Faker;
import csd230.bookstore.entities.*;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import csd230.bookstore.repositories.UserEntityRepository;
import jakarta.transaction.Transactional;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.time.LocalDateTime;


@SpringBootApplication
public class Application implements CommandLineRunner {
    private final ProductEntityRepository productRepository;
    private final CartEntityRepository cartRepository;
    private final UserEntityRepository userRepository;
    private final PasswordEncoder passwordEncoder;


    public Application(ProductEntityRepository productRepository,
                       CartEntityRepository cartRepository,
                       UserEntityRepository userRepository,
                       PasswordEncoder passwordEncoder
    ) {
        this.productRepository = productRepository;
        this.cartRepository = cartRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }


    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }


    @Override
    @Transactional
    public void run(String... args) throws Exception {
        Faker faker = new Faker();
        Commerce cm = faker.commerce();

        // -----------------------------
        // SEED BOOKS
        // -----------------------------
        for (int i = 0; i < 10; i++) {
            String title = faker.book().title();
            String author = faker.book().author();
            String priceString = faker.commerce().price();

            BookEntity book = new BookEntity(
                    title,
                    Double.parseDouble(priceString),
                    10,
                    author
            );

            productRepository.save(book);
            System.out.println("Saved Book " + (i + 1) + ": " + title + " by " + author);
        }

        // -----------------------------
        // SEED MAGAZINES
        // -----------------------------
        for (int i = 0; i < 10; i++) {
            MagazineEntity magazine = new MagazineEntity();
            magazine.setTitle(faker.book().title() + " Magazine");
            magazine.setPrice(Double.parseDouble(faker.commerce().price()));
            magazine.setCopies(faker.number().numberBetween(5, 25));
            magazine.setOrderQty(faker.number().numberBetween(20, 150));
            magazine.setCurrentIssue(LocalDateTime.now().minusDays(faker.number().numberBetween(0, 30)));

            productRepository.save(magazine);
            System.out.println("Saved Magazine " + (i + 1) + ": " + magazine.getTitle());
        }

        // -----------------------------
        // SEED GUITARS
        // -----------------------------
        String[] guitarBrands = {"Fender", "Gibson", "Ibanez", "Yamaha", "PRS", "Epiphone"};
        String[] guitarModels = {"Stratocaster", "Les Paul", "RG", "Pacifica", "Custom 24", "SG"};

        for (int i = 0; i < 10; i++) {
            GuitarEntity guitar = new GuitarEntity();
            guitar.setBrand(guitarBrands[faker.random().nextInt(guitarBrands.length)]);
            guitar.setModel(guitarModels[faker.random().nextInt(guitarModels.length)]);
            guitar.setPrice(Double.parseDouble(faker.commerce().price()));

            productRepository.save(guitar);
            System.out.println("Saved Guitar " + (i + 1) + ": " + guitar.getBrand() + " " + guitar.getModel());
        }

        // -----------------------------
        // SEED DRUM KITS
        // -----------------------------
        String[] drumBrands = {"Pearl", "Yamaha", "Tama", "Ludwig", "Sonor", "Mapex"};

        for (int i = 0; i < 10; i++) {
            DrumKitEntity drumKit = new DrumKitEntity();
            drumKit.setBrand(drumBrands[faker.random().nextInt(drumBrands.length)]);
            drumKit.setPieces(faker.number().numberBetween(4, 8));
            drumKit.setPrice(Double.parseDouble(faker.commerce().price()));

            productRepository.save(drumKit);
            System.out.println("Saved Drum Kit " + (i + 1) + ": " + drumKit.getBrand() + " (" + drumKit.getPieces() + " pieces)");
        }



        // ------------------------------------
        // CREATE USERS (Lecture 2.6)
        // ------------------------------------


        // Admin User (Can Add/Edit/Delete)
        UserEntity admin = new UserEntity("admin", passwordEncoder.encode("admin"), "ADMIN");
        userRepository.save(admin);


        // Regular User (Can only View/Buy)
        UserEntity user = new UserEntity("user", passwordEncoder.encode("user"), "USER");
        userRepository.save(user);


        System.out.println("Default users created: admin/admin and user/user");

        // Check if a cart exists, if not, create one
        if (cartRepository.count() == 0) {
            CartEntity defaultCart = new CartEntity();
            cartRepository.save(defaultCart);
            System.out.println("Default Cart created with ID: " + defaultCart.getId());
        }
    }
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                // Allow access to all /api endpoints from any origin
                registry.addMapping("/api/**").allowedOrigins("*");
            }
        };
    }



}