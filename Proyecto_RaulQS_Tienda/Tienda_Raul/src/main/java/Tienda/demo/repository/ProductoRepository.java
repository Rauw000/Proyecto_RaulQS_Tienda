package Tienda.demo.repository;

import Tienda.demo.domain.Producto;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductoRepository extends JpaRepository<Producto,Integer>{
    public List<Producto> findByActivoTrue();

}