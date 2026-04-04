package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity
@DiscriminatorValue("DRUMKIT")
public class DrumKitEntity extends ProductEntity {

    private String brand;
    private Integer pieces;

    @Column(name = "drumkit_price")
    private Double price;

    public DrumKitEntity() {
    }

    public DrumKitEntity(String brand, Integer pieces, Double price) {
        this.brand = brand;
        this.pieces = pieces;
        this.price = price;
    }

    @Override
    public void sellItem() {
        System.out.println("Selling Drum Kit: " + brand);
    }

    @Override
    public Double getPrice() {
        return price;
    }

    public String getBrand() {
        return brand;
    }

    public Integer getPieces() {
        return pieces;
    }

    public Double getPriceValue() {
        return price;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public void setPieces(Integer pieces) {
        this.pieces = pieces;
    }

    public void setPrice(Double price) {
        this.price = price;
    }
}