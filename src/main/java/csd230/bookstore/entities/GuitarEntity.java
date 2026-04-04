package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("GUITAR")
public class GuitarEntity extends ProductEntity {

    private String brand;
    private String model;

    @Column(name = "guitar_price")
    private Double price;

    public GuitarEntity() {
    }

    public GuitarEntity(String brand, String model, Double price) {
        this.brand = brand;
        this.model = model;
        this.price = price;
    }

    @Override
    public void sellItem() {
        System.out.println("Selling Guitar: " + brand + " " + model);
    }

    @Override
    public Double getPrice() {
        return price;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public void setPrice(Double price) {
        this.price = price;
    }
}