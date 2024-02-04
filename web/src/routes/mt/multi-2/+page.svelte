<script lang="ts">
  let ielem: Element
  let value: string

  const autoresize = (elem: HTMLElement) => {
    const onchange = () => {
      let height = elem.scrollHeight
      // if (height < elem.clientHeight) height = elem.clientHeight
      elem.style.height = `${height}px`

      console.log({ height })
    }

    elem.addEventListener('keyup', onchange, true)
    // elem.addEventListener('change', onchange, true)

    return {
      destroy: () => {
        elem.removeEventListener('keyup', onchange)
        // elem.removeEventListener('change', onchange)
      },
    }
  }
</script>

<form action="." method="POST">
  <label for="qt" class="form-label">Nhập nội dung:</label>
  <textarea
    class="m-input"
    name="qt"
    rows="1"
    placeholder="Nhập tiếng Trung dịch nhanh"
    bind:value
    use:autoresize />
</form>

<style lang="scss">
  textarea {
    width: 100%;
    min-height: 2.5rem;
    max-height: 50vh;
  }
</style>
