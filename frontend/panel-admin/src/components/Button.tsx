import type { ButtonHTMLAttributes, ReactNode } from 'react';

type Variante = 'primario' | 'secundario' | 'peligro' | 'icono';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variante?: Variante;
  chico?: boolean;
  ancho?: boolean;
  cargando?: boolean;
  children?: ReactNode;
}

export function Button({
  variante = 'secundario',
  chico = false,
  ancho = false,
  cargando = false,
  disabled,
  className,
  children,
  ...rest
}: ButtonProps) {
  const clases = [
    'boton',
    `boton--${variante}`,
    chico ? 'boton--chico' : '',
    ancho ? 'boton--ancho' : '',
    className ?? '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button className={clases} disabled={disabled || cargando} {...rest}>
      {cargando ? <span className="spinner" style={{ width: 16, height: 16, borderWidth: 2 }} /> : null}
      {children}
    </button>
  );
}
