package Tienda.demo.services;

import Tienda.demo.domain.Categoria;
import Tienda.demo.repository.CategoriaRepository;
import java.io.File;
import java.util.List;
import java.util.Optional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.dao.DataIntegrityViolationException;
import java.io.IOException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CategoriaService {

    @Autowired
    private CategoriaRepository categoriaRepository;

    @Autowired
    private FirebaseStorageService firebaseStorageService;

    @Transactional(readOnly = true)
    public List<Categoria> getCategorias(boolean activo) {
        if (activo) {
            return categoriaRepository.findByActivoTrue();
        } else {
            return categoriaRepository.findAll();
        }

    }

    @Transactional(readOnly = true)
    public Optional<Categoria> getCategoria(Integer idCategoria) {
        return categoriaRepository.findById(idCategoria);
    }

    @Transactional
    public void save(Categoria categoria, MultipartFile imagenFile) {
        categoria = categoriaRepository.save(categoria);
        if (!imagenFile.isEmpty()) {
            File tempFile = null;
            try {
                // Crear archivo temporal
                tempFile = File.createTempFile("temp", imagenFile.getOriginalFilename());
                imagenFile.transferTo(tempFile);

                // Subir archivo a Firebase
                String rutaImagen = firebaseStorageService.uploadFile(
                        tempFile, "categoria",
                        String.valueOf(categoria.getIdCategoria()));

                // Guardar la URL en la entidad
                categoria.setRutaImagen(rutaImagen);
                categoriaRepository.save(categoria);
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                // Eliminar archivo temporal
                if (tempFile != null && tempFile.exists()) {
                    tempFile.delete();
                }
            }
        }
    }

    @Transactional
    public void delete(Integer idCategoria) {
        if (!categoriaRepository.existsById(idCategoria)) {
            throw new IllegalArgumentException("La categoria con ID " + idCategoria + " no existe.");
        }
        try {
            categoriaRepository.deleteById(idCategoria);
        } catch (DataIntegrityViolationException e) {
            throw new IllegalStateException("No se puede eliminar la categoria. Tiene datos asociados.", e); // Agregué la coma faltante
        }
    }
}
