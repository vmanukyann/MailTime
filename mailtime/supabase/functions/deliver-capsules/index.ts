import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async () => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const now = new Date().toISOString()

  const { data: capsulesToDeliver, error } = await supabaseClient
    .from('capsules')
    .select('*')
    .lte('delivery_date', now)
    .eq('is_delivered', false)

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  const capsuleIds = capsulesToDeliver?.map((capsule) => capsule.id) ?? []

  if (capsuleIds.length > 0) {
    const { error: updateError } = await supabaseClient
      .from('capsules')
      .update({
        is_delivered: true,
        delivered_at: now,
      })
      .in('id', capsuleIds)

    if (updateError) {
      return new Response(JSON.stringify({ error: updateError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      delivered_count: capsuleIds.length,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
