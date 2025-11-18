package Tienda.demo.controller;

import Tienda.demo.domain.Categoria;
import Tienda.demo.services.CategoriaService;
import Tienda.demo.services.FirebaseStorageService;
import java.util.Locale;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/categoria")
public class CategoriaController {

    @Autowired
    private CategoriaService categoriaService;

    @GetMapping
    public String redirigirAlListado() {
        return "redirect:/categoria/listado";
    }

    @GetMapping("/listado")
    public String listado(Model model) {
        var categorias = categoriaService.getCategorias(false);
        model.addAttribute("categorias", categorias);
        model.addAttribute("totalCategorias", categorias.size());
        return "/categoria/listado";
    }
    @Autowired
    private FirebaseStorageService firebaseStorageService;
    @Autowired
    private MessageSource messageSource;
    
    @PostMapping("/guardar")
    public String guardar (Categoria categoria,
            @RequestParam MultipartFile imagenFile,
            RedirectAttributes redirectAttributes){
        if(!imagenFile.isEmpty()){
            categoriaService.save(categoria);
            String rutaImagen
                    = firebaseStorageService.cargaImagen(imagenFile, "categoria", categoria.getIdCategoria());
            categoria.setRutaImagen(rutaImagen);
        }
        categoriaService.save(categoria);
        redirectAttributes.addFlashAttribute("todo OK",
                null,
                Locale.getDeafault());
        return "redirect:/categoria/listado";
    }
    @PostMapping("/eliminar")
    public String eliminar(Categoria categoria, RedirectAttributes redirectAttributes){
        categoria =categoriaService.getCategoria(categoria);
        if (categoria == null){
            rediretAttributes.addFlashAttribute("error",
                    messageSource.getMessage("categoria.error01",
                            null,
                            Locale.getDefault()));
        }else if (false){
            redirectAttributes.addFlashAttribute("error",
                    messageSource.getMessage("categoria.error02",
                            null,
                            Locale.getDefault()));
        }else if (categoriaService.delete(categoria)){
            redirectAttributes.addFlashAttribute("todo Ok",
                    null,
                    Locale.getDefault());
        } else{
            redirectAttributes.addFlashAttribute("error",
                    messageSource.getMessage("categoria.error03", 
                            null,
                            Locale.getDefault()));
        }
        return "redirect:/categoria/listado";
    }
    @PostMapping("/modificar")
    public String modificar (Categoria categoria, Model model){
        categoria = categoriaService.getCategoria(categoria);
        model.addAllAttributes("categoria", categoria);
        return "/categoria/modificar";
    }
}
