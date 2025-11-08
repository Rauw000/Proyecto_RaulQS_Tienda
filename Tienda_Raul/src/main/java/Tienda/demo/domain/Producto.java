package Tienda.demo.domain;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.io.Serializable;
import java.math.BigDecimal;
import lombok.Data;


@Data
@Entity
@Table(name = "producto")
public class Producto implements Serializable {
    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column (name = "id_producto")
    private Integer IdProducto;
    private Integer IdCategoria;
    
    @Column(nullable = false, length = 50)
    @NotBlank(message = "La descripción no puede estar vacia.")
    @Size(max = 50, message = "La descripción no puede tener mas de 50 caracteres.")
    private String descripcion;
    
    @Column (columnDefinition = "TEXT")
    private String detalle;
    
    @Column (precision = 12, scale = 2)
    @NotNull(message = "El precio no puede estar vacio.")
    @DecimalMin(value = "0.01", inclusive = true, message = "El precio debe ser mayor a 0.")
    private BigDecimal precio;
    
    @NotNull(message = "El campo de existencias no puede estar vacio.")
    @Min(value = 0, message = "Las existencias deben ser un numero mayor o igual a 0.")
    private Integer existencias;
    
    @Column(name = "ruta_imagen", length = 1024)
    private String rutaImagen;
    private boolean activo;
    
    @ManyToOne
    @JoinColumn(name = "id_Categoria")
    private Categoria catrgoria;
    
}
